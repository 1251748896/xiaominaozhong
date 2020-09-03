//
//  KeyInputTextField.m
//  Car
//
//  Created by bo.chen on 17/5/16.
//  Copyright © 2017年 com.smaradio. All rights reserved.
//

#import "KeyInputTextField.h"

@implementation KeyInputTextField

- (void)deleteBackward {
    if (self.text.length == 0) {
        if (self.keyInputDelegate && [self.keyInputDelegate respondsToSelector:@selector(deleteBackward:)]) {
            [self.keyInputDelegate deleteBackward:self];
        }
    } else {
        [super deleteBackward];
    }
}

@end
