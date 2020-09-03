//
//  RepeatMonthCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/11.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "RepeatMonthCell.h"

@implementation RepeatMonthCell {
    NSMutableArray  *_btnArray;
    UIView  *_circleView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _circleView.layer.cornerRadius = 15;
        _circleView.layer.masksToBounds = YES;
        _circleView.backgroundColor = HexRGBA(0x00A94B, 255);
        [self.contentView addSubview:_circleView];
        
        CGFloat btnWidth = (deviceWidth-30)/7;
        
        _btnArray = [NSMutableArray arrayWithCapacity:31];
        for (NSInteger i = 0; i < 31; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(15 + (i % 7) * btnWidth, 30 + (i / 7) * 30, btnWidth, 30);
            
            [btn setTitleColor:HexGRAY(0x66, 255) forState:UIControlStateNormal];
            [btn setTitleColor:HexGRAY(0xFF, 255) forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            
            [btn setTitle:[NSString stringWithFormat:@"%@", @(i+1)] forState:UIControlStateNormal];
            btn.tagObj = @(i+1);
            
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

- (void)setSelectedDay:(NSNumber *)selectedDay {
    _selectedDay = selectedDay;
    
    for (UIButton *btn in _btnArray) {
        btn.selected = [btn.tagObj isEqual:_selectedDay];
        if (btn.selected) {
            _circleView.center = btn.center;
        }
    }
}

- (void)btnPressed:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    if (self.tapBlock) {
        self.tapBlock(sender.tagObj);
    }
    self.selectedDay = sender.tagObj;
}

+ (CGFloat)height {
    return 30+5*30+30;
}

@end
