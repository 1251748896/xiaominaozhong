//
//  RepeatWeekdayCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/11.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "RepeatWeekdayCell.h"

@implementation RepeatWeekdayCell {
    NSMutableArray  *_btnArray;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat btnWidth = (deviceWidth-30-16*2*scaleRatio)/3;
        
        static NSString *titleStrs[] = {@"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", @"星期日"};
        
        _btnArray = [NSMutableArray arrayWithCapacity:7];
        for (NSInteger i = 0; i < 7; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(15 + (i % 3) * (btnWidth + 16*scaleRatio), 40 + (i / 3) * (32 + 10), btnWidth, 32);
            btn.layer.borderColor = HexGRAY(0xE6, 255).CGColor;
            btn.layer.borderWidth = 0.5;
            btn.layer.cornerRadius = 16;
            btn.layer.masksToBounds = YES;
            
            [btn setBackgroundImage:[UIImage imageWithColor:HexGRAY(0xFF, 255) andSize:CGSizeMake(1, 1)] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageWithColor:HexRGBA(0x00A94B, 255) andSize:CGSizeMake(1, 1)] forState:UIControlStateSelected];
            
            [btn setTitleColor:HexGRAY(0x66, 255) forState:UIControlStateNormal];
            [btn setTitleColor:HexGRAY(0xFF, 255) forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            
            [btn setTitle:titleStrs[i] forState:UIControlStateNormal];
            if (i == 6) {
                btn.tagObj = @1;
            } else {
                btn.tagObj = @(i+2);
            }
            
            [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:btn];
            [_btnArray addObject:btn];
        }
        
        [self.line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.equalTo(self).mas_offset(-15);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}

- (void)setSelectedWeekday:(NSNumber *)selectedWeekday {
    _selectedWeekday = selectedWeekday;
    
    for (UIButton *btn in _btnArray) {
        btn.selected = [btn.tagObj isEqual:selectedWeekday];
    }
}

- (void)btnPressed:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    if (self.tapBlock) {
        self.tapBlock(sender.tagObj);
    }
    self.selectedWeekday = sender.tagObj;
}

+ (CGFloat)height {
    return 40+3*(32+10)+40;
}

@end
