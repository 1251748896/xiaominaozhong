//
//  ShiftWorkBtnCell.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/8.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface ShiftWorkBtnCell : BaseTableViewCell
@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, copy) ObjectBlock tapBlock;
@end

@interface ShiftBlankCell : BaseTableViewCell

@end
