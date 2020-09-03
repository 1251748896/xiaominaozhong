//
//  VoicePlayer.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/7.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "VoicePlayer.h"
#import <AVFoundation/AVFoundation.h>

static void completionCallback(SystemSoundID ssID, void *clientData)
{
    AudioServicesPlaySystemSound(ssID);
}

@interface VoicePlayer ()
<AVAudioPlayerDelegate>
{
    AVAudioPlayer   *_player;
    SystemSoundID   _soundID;
    CGFloat _oldSystemVolume;
}
@end

@implementation VoicePlayer

- (void)stop {
#if 0
    if (_player) {        
        _player.delegate = nil;
        [_player stop];
        _player = nil;
    }
#else
    if (_soundID != 0) {
        AudioServicesRemoveSystemSoundCompletion(_soundID);
        AudioServicesDisposeSystemSoundID(_soundID);
        _soundID = 0;
    }
#endif
}

+ (instancetype)sharedInstance {
    static VoicePlayer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VoicePlayer alloc] init];
    });
    return instance;
}

- (void)playUrl:(NSURL *)url loops:(NSInteger)loops {
#if 0
    NSError *err = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&err];
    if (err) {
        DEBUG_LOG(@"%@", err);
    }
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    if (err) {
        DEBUG_LOG(@"%@", err);
    }
    
    if (_player) {
        _player.numberOfLoops = loops;
        [_player setVolume:1.0];
        _player.delegate = self;
        [_player play];
    }
#else
    SystemSoundID theSoundID;
    OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &theSoundID);
    if (error == kAudioServicesNoError) {
        _soundID = theSoundID;
        AudioServicesAddSystemSoundCompletion(theSoundID, NULL, NULL, completionCallback, NULL);
        AudioServicesPlaySystemSound(theSoundID);
    } else {
        DEBUG_LOG(@"Failed to create sound ");
    }
#endif
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
}

@end
