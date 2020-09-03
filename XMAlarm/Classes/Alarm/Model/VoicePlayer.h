//
//  VoicePlayer.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/7.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoicePlayer : NSObject

+ (instancetype)sharedInstance;

- (void)playUrl:(NSURL *)url loops:(NSInteger)loops;
- (void)stop;

@end
