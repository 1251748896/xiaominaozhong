//
//  ALImageView.m
//  goodnight
//
//  Created by mac003 on 15/4/10.
//  Copyright (c) 2015年 quleduo. All rights reserved.
//

#import "ALImageView.h"

@implementation ALImageView

- (void)initialize {
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:gesture];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)setDelegate:(id<ALImageViewDelegate>)delegate {
    self.userInteractionEnabled = nil != delegate;
    _delegate = delegate;
}

- (void)handleTapGesture:(id)gesture {
    if (_delegate && [_delegate respondsToSelector:@selector(touchUpInside:)]) {
        [_delegate touchUpInside:self];
    }
}

@end
