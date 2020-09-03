//
//  RemindLaterAlertView.m
//  XMAlarm
//
//  Created by bo.chen on 17/11/7.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "RemindLaterAlertView.h"
#import "InputLaterAlertView.h"

@interface RemindLaterAlertView ()
{
    NSMutableArray  *_btnArray;
}
@property (nonatomic, weak) CustomIOSAlertView *alertView;
@end

@implementation RemindLaterAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, deviceWidth-20, 240)];
    if (self) {
        _btnArray = [NSMutableArray array];
        
        NSArray *dataSource = @[@{@"title": @"15分钟", @"icon": @"icon_choice_clock15", @"val": @15},
                                @{@"title": @"30分钟", @"icon": @"icon_choice_clock30", @"val": @30},
                                @{@"title": @"1小时", @"icon": @"icon_choice_clock1h", @"val": @60},
                                @{@"title": @"3小时", @"icon": @"icon_choice_clock3h", @"val": @(3*60)},
                                @{@"title": @"6小时", @"icon": @"icon_choice_clock6h", @"val": @(6*60)},
                                @{@"title": @"自定义", @"icon": @"icon_choice_clock_custom", @"val": @(-1)}];
        
        CGFloat width = (self.width-20)/3;
        for (NSInteger i = 0; i < 2; i++) {
            for (NSInteger j = 0; j < 3; j++) {
                NSInteger index = i*3+j;
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(10+width*j, 20+100*i, width, 100);
                btn.titleLabel.font = [UIFont systemFontOfSize:Expand6(12, 13)];
                [btn setTitleColor:HexRGBA(0x666666, 255) forState:UIControlStateNormal];
                NSDictionary *dataDict = safeGetArrayObject(dataSource, index);
                [btn setTitle:dataDict[@"title"] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:dataDict[@"icon"]] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                [btn layoutButtonWithEdgeInsetsStyle:ButtonEdgeInsetsStyleImageTop imageTitlespace:8];
                btn.tagObj = dataDict;
                [self addSubview:btn];
                [_btnArray addObject:btn];
            }
        }
    }
    return self;
}

- (void)btnPressed:(UIButton *)sender {
    NSDictionary *dataDict = sender.tagObj;
    if ([dataDict[@"val"] integerValue] == -1) {
        WeakSelf
        InputLaterAlertView *alertView = [[InputLaterAlertView alloc] initWithFrame:CGRectZero];
        alertView.sureBlock = ^(NSNumber *minutes) {
            if (weakSelf.sureBlock) {
                weakSelf.sureBlock(minutes);
            }
            [weakSelf.alertView close];
        };
        [alertView show];
    } else {
        if (self.sureBlock) {
            self.sureBlock(dataDict[@"val"]);
        }
        [self.alertView close];
    }
}

- (void)show {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] initWithTitle:@""];
    alertView.containerView = self;
    alertView.buttonTitles = @[@"取消"];
    alertView.delegate = NULL;//为null，不会自动close
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (0 == buttonIndex) {
            [alertView close];
        }
    }];
    [alertView show];
    self.alertView = alertView;
}

@end
