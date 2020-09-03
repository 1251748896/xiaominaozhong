//
//  TrafficSwitchCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/20.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "TrafficSwitchCell.h"
#import "SwitchButton.h"

#define kInfoFont [UIFont systemFontOfSize:Expand6(12, 13)]

@implementation TrafficSwitchCell {
    UILabel     *_titleLbl;
    SwitchButton    *_switchBtn;
    UILabel     *_infoLbl;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.textColor = HexRGBA(0x333333, 255);
        _titleLbl.font = [UIFont systemFontOfSize:Expand6(14, 15)];
        [self.contentView addSubview:_titleLbl];
        
        _switchBtn = [[SwitchButton alloc] init];
        [_switchBtn addTarget:self action:@selector(switchBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_switchBtn];
        
        _infoLbl = [[UILabel alloc] init];
        _infoLbl.textColor = HexRGBA(0x666666, 255);
        _infoLbl.font = kInfoFont;
        _infoLbl.numberOfLines = 0;
        [self.contentView addSubview:_infoLbl];
        
        [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.equalTo(_switchBtn.mas_left).mas_offset(-15);
            make.height.mas_equalTo(20);
            make.centerY.equalTo(_switchBtn);
        }];
        [_switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLbl.mas_right).mas_offset(15);
            make.right.equalTo(self).mas_offset(-15);
            make.size.mas_equalTo(CGSizeMake(55, 25));
            make.top.mas_equalTo(15);
        }];
        [_infoLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLbl);
            make.right.equalTo(_switchBtn);
            make.top.equalTo(_switchBtn.mas_bottom).mas_offset(10);
            make.bottom.equalTo(self).mas_offset(-10);
        }];
    }
    return self;
}

- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    
    _titleLbl.text = dataDict[@"title1"];
    _infoLbl.text = dataDict[@"title2"];
    _switchBtn.on = [dataDict[@"open"] boolValue];
}

- (void)switchBtnPressed:(id)sender {
    _switchBtn.on = !_switchBtn.on;
    
    if (self.tapSwitchBlock) {
        self.tapSwitchBlock(@(_switchBtn.on));
    }
}

+ (CGFloat)heightWithDataDict:(NSDictionary *)dataDict {
    CGFloat height = 15+25+10;
    CGSize size = MB_MULTILINE_TEXTSIZE(dataDict[@"title2"], kInfoFont, CGSizeMake(deviceWidth-30, CGFLOAT_MAX));
    height += ceilf(size.height)+10;
    return height;
}

@end
