//
//  DisclaimerAlertView.m
//  XMAlarm
//
//  Created by bo.chen on 2017/11/21.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "DisclaimerAlertView.h"

@implementation DisclaimerAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, deviceWidth-20, 240)];
    if (self) {
        CGFloat top = 25;
        
        UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(30, top, self.width-60, 20)];
        lbl1.textColor = HexRGBA(0x373737, 255);
        lbl1.font = [UIFont systemFontOfSize:Expand6(15, 16)];
        lbl1.text = @"下列情况无法响铃！";
        [self addSubview:lbl1];
        top += lbl1.height+20;
        
        CGFloat gap = (self.width-lbl1.left*2-4*36)/3;
        static NSString *iconNames[] = {@"disclaimer_silence", @"disclaimer_ear", @"disclaimer_nodisturb", @"disclaimer_nonotification"};
        for (NSInteger i = 0; i < 4; i++) {
            UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconNames[i]]];
            iconView.left = lbl1.left+(36+gap)*i;
            iconView.top = top;
            [self addSubview:iconView];
        }
        
        top += 20+36;
        
        static NSString *infoStrs[] = {@"手机静音或关机。", @"插着耳机。", @"在勿扰模式状态中并锁屏，(详见：设置>通知>勿扰模式>说明)。", @"通知中心未开启小秘闹钟的通知。"};
        for (NSInteger i = 0; i < 4; i++) {
            UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(lbl1.left, top, 18, 20)];
            lbl2.textColor = HexRGBA(0x373737, 255);
            lbl2.font = [UIFont systemFontOfSize:Expand6(15, 16)];
            lbl2.text = [NSString stringWithFormat:@"%@.", @(i+1)];
            [self addSubview:lbl2];
            
            UILabel *lbl3 = [[UILabel alloc] initWithFrame:CGRectMake(lbl2.right, top, lbl1.right-lbl2.right, 1)];
            lbl3.textColor = HexRGBA(0x373737, 255);
            lbl3.font = [UIFont systemFontOfSize:Expand6(15, 16)];
            lbl3.numberOfLines = 0;
            lbl3.text = infoStrs[i];
            [self addSubview:lbl3];
            CGSize size = MB_MULTILINE_TEXTSIZE(lbl3.text, lbl3.font, CGSizeMake(lbl3.width, CGFLOAT_MAX));
            lbl3.height = MAX(20, ceilf(size.height));
            
            top += lbl3.height+6;
        }
        top += 15;
        
        self.height = top;
    }
    return self;
}

- (void)show {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] initWithTitle:@"重要提醒"];
    alertView.containerView = self;
    alertView.buttonTitles = @[@"不再提醒", @"知道了"];
    alertView.delegate = NULL;//为null，不会自动close
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (0 == buttonIndex) {
            [User_Default setObject:@YES forKey:kDisclaimerKnownKey];
            [User_Default synchronize];
            [alertView close];
        } else if (1 == buttonIndex) {
            [alertView close];
        }
    }];
    [alertView show];
}

@end
