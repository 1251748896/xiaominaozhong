//
//  AsyncDataCell.m
//  XMAlarm
//
//  Created by Mac mini on 2018/4/27.
//  Copyright © 2018年 com.xmm. All rights reserved.
//

#import "AsyncDataCell.h"

@implementation AsyncDataCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _cellImgv = [[UIImageView alloc] init];
        _cellImgv.image = [UIImage imageNamed:@"蓝牙-3.png"];
        _cellImgv.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_cellImgv];
        
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.text = @"同步数据";
        _statusLabel.textColor = HexRGBA(0x333333, 255);
        _statusLabel.font = [UIFont systemFontOfSize:Expand6(14, 15)];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_statusLabel];
        
        _promitLabel = [[UILabel alloc] init];
        _promitLabel.text = @"(用于题鸣限行提醒器)";
        _promitLabel.textColor = HexRGBA(0x666666, 255);
        _promitLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_promitLabel];
        
        [_cellImgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(15);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.width.mas_equalTo(30);
            make.height.mas_equalTo(30);
        }];
        
        [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY).offset(-7);
            make.centerX.equalTo(self.contentView.mas_centerX);
        }];
        
        [_promitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.statusLabel.mas_bottom).offset(3);
            make.centerX.equalTo(self.contentView.mas_centerX);
        }];
        
        UIView *_line = [[UIView alloc] init];
        _line.backgroundColor = HexGRAY(0xE3, 255);
        [self.contentView addSubview:_line];
        [_line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(15);
            make.right.equalTo(self.contentView.mas_right).offset(-15);
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.height.equalTo(@0.5);
        }];
        
        
    }
    return self;
}

- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
}

+ (CGFloat)height {
    return Expand6(50, 54);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
