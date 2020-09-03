//
//  ShiftWorkBtnCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/8.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "ShiftWorkBtnCell.h"
#import "ShiftWorkBtn.h"

@implementation ShiftWorkBtnCell {
    NSMutableArray  *_itemArray;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.line.hidden = YES;
        
        _itemArray = [NSMutableArray arrayWithCapacity:3];
        for (NSInteger i = 0; i < 3; i++) {
            ShiftWorkBtn *item = [[ShiftWorkBtn alloc] init];
            [item addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:item];
            [_itemArray addObject:item];
        }
        [_itemArray mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(6);
            make.bottom.equalTo(self).mas_offset(-5);
        }];
        [_itemArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:79*scaleRatio leadSpacing:15 tailSpacing:15];
    }
    return self;
}

- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    
    NSArray *dataArray = (NSArray *)dataDict;
    for (NSInteger i = 0; i < 3; i++) {
        ShiftWorkBtn *item = _itemArray[i];
        if (i < dataArray.count) {
            item.hidden = NO;
            item.workInfo = dataArray[i];
        } else {
            item.hidden = YES;
        }
    }
}

- (void)btnPressed:(ShiftWorkBtn *)sender {
    if (self.tapBlock) {
        self.tapBlock(sender.workInfo);
    }
}

@end

@implementation ShiftBlankCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.equalTo(self).mas_offset(-15);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}

@end
