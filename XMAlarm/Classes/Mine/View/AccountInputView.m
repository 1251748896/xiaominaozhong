//
//  AccountInputView.m
//  Car
//
//  Created by bo.chen on 16/12/5.
//  Copyright © 2016年 com.smaradio. All rights reserved.
//

#import "AccountInputView.h"

@implementation AccountInputView

- (instancetype)initWithIconName:(NSString *)iconName placeholder:(NSString *)placeholder {
    self = [super init];
    if (self) {
        self.layer.borderColor = HexRGBA(0xD1D6DE, 255).CGColor;
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;
        
        UIImageView *accountIcon = [[UIImageView alloc] init];
        accountIcon.image = [UIImage imageNamed:iconName];
        accountIcon.contentMode = UIViewContentModeCenter;
        [self addSubview:accountIcon];
        
        _textFd = [[UITextField alloc] init];
        _textFd.backgroundColor = [UIColor clearColor];
        _textFd.textColor = HexRGBA(0x333333, 255);
        _textFd.font = [UIFont systemFontOfSize:Expand6(14, 15)];
        _textFd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: HexRGBA(0xB3B3B3, 255)}];
        [self addSubview:_textFd];
        
        [accountIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.size.mas_equalTo(CGSizeMake(35, 30));
            make.centerY.equalTo(self);
        }];
        [_textFd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(accountIcon.mas_right).mas_offset(@1);
            make.top.bottom.right.equalTo(self);
        }];
    }
    return self;
}

//如果返回nil。 表示value符合要求。否则返回错误的信息
- (NSString *)checkValueError {
    NSString *errorStr = nil;
    NSString *formValueStr = self.textFd.text;
    
    if (formValueStr == nil || formValueStr.length < 1) {
        errorStr = [NSString stringWithFormat:@"请输入%@", self.objName];
    }
    else {
        if (self.regex) {
            NSPredicate *regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", self.regex];
            if (![regexPredicate evaluateWithObject:formValueStr]) {
                errorStr = [NSString stringWithFormat:@"请输入正确的%@", self.objName];
            }
        }
    }
    return errorStr;
}

@end
