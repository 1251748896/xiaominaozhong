//
//  BackgroundModeManager.m
//  PrintServer
//
//  Created by bo.chen on 15/7/29.
//  Copyright (c) 2015年 Beijing ShiShiKe Technologies Co., Ltd. All rights reserved.
//

#import "BackgroundModeManager.h"
#import <AVFoundation/AVFoundation.h>

@interface BackgroundModeManager ()
{
    AVAudioPlayer   *_player;
    NSTimer     *_timer;
}
@end

@implementation BackgroundModeManager

+ (instancetype)sharedInstance {
    static BackgroundModeManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BackgroundModeManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepareAudio];
    }
    return self;
}

- (void)openBackgroundMode {
    // 开启后台播放
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:NULL];
    [self startTimer];
}

- (void)stopBackgroundMode {
    [self stopTimer];
}

- (BOOL)prepareAudio {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"keepawake" ofType:@"wav"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return NO;
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    if (!_player) {
        return NO;
    }
    
    _player.volume = 1.0;
    _player.numberOfLoops = 0;
    [_player prepareToPlay];
    return YES;
}

- (void)startTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(tik) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)playAudio {
    if (_player.isPlaying) {
        [_player stop];
    }
    
    [_player play];
}

- (void)tik {
    [self playAudio];
    
    __block UIBackgroundTaskIdentifier identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:identifier];
        identifier = UIBackgroundTaskInvalid;
    }];
}

@end
