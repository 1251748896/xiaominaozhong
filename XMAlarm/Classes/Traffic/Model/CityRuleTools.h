//
//  CityRuleTools.h
//  XMAlarm
//
//  Created by Mac mini on 2018/11/2.
//  Copyright © 2018年 com.xmm. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CityRuleTools : NSObject
/*
 10: 不是半限行城市,且 是限行城市
 11: 是半限行城市,且显示详情
 12: 是半限行城市,且不显示详情
 13, 完全不限行的城市 不显示
 */
+ (void)showDetailInfo:(id)model finish:(void (^)(int state))finish;
@end

NS_ASSUME_NONNULL_END
