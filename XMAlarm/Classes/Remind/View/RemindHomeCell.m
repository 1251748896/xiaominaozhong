//
//  RemindHomeCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/10.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "RemindHomeCell.h"
#import "RepeatRemind.h"
#import "TempRemind.h"

@implementation RemindHomeCell

- (void)appendOtherTitleStr:(NSMutableAttributedString *)attrStr {
    if ([self.alarm isMemberOfClass:[RepeatRemind class]]) {
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)", [(RepeatRemind *)self.alarm formatRepeatStr]] attributes:@{NSForegroundColorAttributeName: HexRGBA(0x757575, 255), NSFontAttributeName: [UIFont systemFontOfSize:13]}]];
    } else if ([self.alarm isMemberOfClass:[TempRemind class]]) {
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)", [(TempRemind *)self.alarm formatDateStr]] attributes:@{NSForegroundColorAttributeName: HexRGBA(0x757575, 255), NSFontAttributeName: [UIFont systemFontOfSize:13]}]];
    }
}

@end
