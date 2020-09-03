//
//  NameAlertView.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "NameAlertView.h"

@interface NameAlertView ()
<UITextFieldDelegate>
{
    UITextField *_nameFd;
}
@property (nonatomic, strong) NSString *title;
@property (nonatomic, weak) CustomIOSAlertView *alertView;
@end

@implementation NameAlertView

- (instancetype)initWithTitle:(NSString *)title name:(NSString *)name placeholder:(NSString *)placeholder {
    self = [super initWithFrame:CGRectMake(0, 0, deviceWidth-20, 80)];
    if (self) {
        self.title = title;
        
        UIView *borderBg = [[UIView alloc] init];
        borderBg.layer.borderColor = HexGRAY(0xE3, 255).CGColor;
        borderBg.layer.borderWidth = 0.5;
        borderBg.layer.cornerRadius = 2;
        borderBg.layer.masksToBounds = YES;
        [self addSubview:borderBg];
        
        _nameFd = [[UITextField alloc] init];
        _nameFd.delegate = self;
        _nameFd.textColor = HexGRAY(0x33, 255);
        _nameFd.font = [UIFont systemFontOfSize:15];
        _nameFd.placeholder = placeholder;
        _nameFd.text = name;
        [_nameFd addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:_nameFd];
        
        UILabel *lbl = [[UILabel alloc] init];
        lbl.textColor = HexGRAY(0x99, 255);
        lbl.font = [UIFont systemFontOfSize:11];
        lbl.text = @"20个字符以内";
        [self addSubview:lbl];
        
        [borderBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(45);
            make.right.equalTo(self).mas_offset(-15);
        }];
        [_nameFd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(borderBg).mas_offset(10);
            make.right.equalTo(borderBg).mas_offset(-10);
            make.top.height.equalTo(borderBg);
        }];
        [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(borderBg.mas_left).mas_offset(5);
            make.right.equalTo(borderBg);
            make.top.equalTo(borderBg.mas_bottom).mas_offset(5);
            make.height.mas_equalTo(20);
        }];
    }
    return self;
}

- (void)show {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] initWithTitle:self.title];
    alertView.containerView = self;
    alertView.buttonTitles = @[@"取消", @"确定"];
    alertView.delegate = NULL;//为null，不会自动close
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (0 == buttonIndex) {
            [alertView close];
        } else if (1 == buttonIndex) {
            if (_nameFd.text.length > 0 && self.sureBlock) {
                self.sureBlock([_nameFd.text substringToIndex:MIN(20, _nameFd.text.length)]);
            }
            [alertView close];
        }
    }];
    [alertView show];
    alertView.titleLine.hidden = YES;
    self.alertView = alertView;
}

- (void)textFieldDidChanged:(UITextField *)sender {
}

@end
