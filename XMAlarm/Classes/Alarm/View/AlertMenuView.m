//
//  AlertMenuView.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "AlertMenuView.h"

@interface AlertMenuView ()
@property (nonatomic, strong) NSString *title;
@property (nonatomic, weak) CustomIOSAlertView *alertView;
@end

@implementation AlertMenuView

- (instancetype)initWithTitle:(NSString *)title dataSource:(NSArray *)dataSource {
    self = [super initWithFrame:CGRectMake(0, 0, deviceWidth-108, dataSource.count*44)];
    if (self) {
        self.title = title;
        
        for (NSInteger i = 0; i < dataSource.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(13, 44*i, self.width-26, 44);
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            [btn setTitleColor:HexRGBA(0x333333, 255) forState:UIControlStateNormal];
            [btn setTitle:dataSource[i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i;
            [self addSubview:btn];
            
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = HexRGBA(0xE3E3E3, 255);
            [self addSubview:line];
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.width.bottom.equalTo(btn);
                make.height.mas_equalTo(0.5);
            }];
        }
    }
    return self;
}

- (void)show {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] initWithTitle:self.title];
    alertView.containerView = self;
    alertView.buttonTitles = @[@"取消"];
    [alertView show];
    self.alertView = alertView;
}

- (void)btnPressed:(UIButton *)sender {
    if (self.indexBlock) {
        self.indexBlock(sender.tag);
    }
    [self.alertView close];
}

@end
