//
//  CityRuleTools.m
//  XMAlarm
//
//  Created by Mac mini on 2018/11/2.
//  Copyright © 2018年 com.xmm. All rights reserved.
//

#import "CityRuleTools.h"
#import "TrafficLimitAlarm.h"
#import <UIKit/UIKit.h>
@implementation CityRuleTools
/*
 10: 不是半限行城市,且 是限行城市
 11: 是半限行城市,且显示详情
 12: 是半限行城市,且不显示详情
 13, 完全不限行的城市 不显示
 */
+ (void)showDetailInfo:(id)model finish:(nonnull void (^)(int))finish {
    
    if (![model isKindOfClass:[TrafficLimitAlarm class]]) {
        finish(13);
        return;
    }
    TrafficLimitAlarm * mo = model;
    if (mo.limitRule == nil) {
        finish(13);
        return;
    }
    int mid = [mo.city.mid intValue];
    NSString *limitTip = [NSString stringWithFormat:@"%@",mo.limitRule.limitTip];
    NSString *otherTip = [NSString stringWithFormat:@"%@",mo.limitRule.otherTip];
    if (limitTip.length == 0) {
        limitTip = otherTip;
    }
    if (mid == 20 || mid == 39 || mid == 924) {
        /*
         天津(20)：本地车和外地车一样
         石家庄(39)、保定(125)、廊坊(196)、杭州(924)：本地车和外地车不一样，都bu要显示详情
         */
        
        NSString *pla = mo.limitRule.plateNumberPre;
//        if (![pla contains:@"A"] && pla.length == 1) {
//            mo.limitRule.plateNumberPre = [NSString stringWithFormat:@"%@A",pla];
//        }
        
        if ([mo.plateNumber hasPrefix:pla]) {
            //本地车
            finish(10);
        } else {
            if (limitTip.length) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:limitTip cancelButtonTitle:@"确定"];
                [alertView showUsingBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    finish(12);
                }];
            } else {
                finish(12);
            }
        }
        return;
    } else if (mid == 2) {
        //1.北京
        if ([mo.plateNumber hasPrefix:mo.limitRule.plateNumberPre]) {
            //本地车
            finish(11);
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否有进京证？" cancelButtonTitle:@"否" otherButtonTitle:@"是"];
            [alertView showUsingBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (0 == buttonIndex) {
                    //没证
                    if (limitTip.length) {
                        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:limitTip cancelButtonTitle:@"确定"];
                        [al showUsingBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            finish(12);
                        }];
                    } else {
                        finish(12);
                    }
                } else if (1 == buttonIndex) {
                    //有证
                    finish(11);
                }
            }];
        }
        return;
    } else if (mid == 581) {
        //2.长春
        if ([mo.plateNumber hasPrefix:mo.limitRule.plateNumberPre]) {
            //本地车 --模式3限行
            finish(11);
        } else {
            // 外地车不限行
            finish(12);
        }
        return;
    } else if (mid == 794 || mid == 1940 || mid == 1963) {
        //3.上海/广州/深圳
        if ([mo.plateNumber hasPrefix:mo.limitRule.plateNumberPre]) {
            //本地车不限行
            finish(12);
        } else {
            if (limitTip.length == 0) {
                finish(11);
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:limitTip cancelButtonTitle:@"确定"];
                [alertView showUsingBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    finish(11);
                }];
            }
        }
        return;
    } else if (mid == 2485) {
        
        //4.贵阳
        if ([mo.plateNumber hasPrefix:mo.limitRule.plateNumberPre]) {
            //本地车
             BOOL isNum = NO;
            if (mo.plateNumber.length > mo.limitRule.plateNumberPre.length) {
                NSString *last = [mo.plateNumber substringFromIndex:mo.plateNumber.length-1];
                NSLog(@"last = %@",last);
                NSArray *nums = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
                isNum = [nums containsObject:last];
            }
            if (isNum) {
                finish(11);
                return;
            }
            finish(12);
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否已登记备案？" cancelButtonTitle:@"否" otherButtonTitle:@"是"];
            [alertView showUsingBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (0 == buttonIndex) {
                    // 没有备案
                    finish(12);
                } else if (1 == buttonIndex) {
                    //
                    finish(11);
                }
            }];
        }
        return;
    } else if (mid == 2929) {
        //兰州
        if ([mo.plateNumber hasPrefix:mo.limitRule.plateNumberPre]) {
            //本地车
            finish(11);
        } else {
            finish(12);
        }
        return;
    }
    finish(10);
}

@end
