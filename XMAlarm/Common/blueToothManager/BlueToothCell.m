//
//  BlueToothCell.m
//  XMAlarm
//
//  Created by Mac mini on 2018/4/28.
//  Copyright © 2018年 com.xmm. All rights reserved.
//

#import "BlueToothCell.h"

@implementation BlueToothCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        [self.contentView addSubview:self.activityIndicator];
        //设置小菊花的frame
        //        self.activityIndicator.frame= CGRectMake(100, 100, 100, 100);
        //设置小菊花颜色
        _activityIndicator.color = [UIColor grayColor];
        //设置背景颜色
        _activityIndicator.backgroundColor = [UIColor whiteColor];
        //刚进入这个界面会显示控件，并且停止旋转也会显示，只是没有在转动而已，没有设置或者设置为YES的时候，刚进入页面不会显示
        _activityIndicator.hidesWhenStopped = NO;
        
        [_activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.left.equalTo(self.contentView.mas_left).offset(15);
        }];
        
        _statusImgv = [[UIImageView alloc] init];
        _statusImgv.hidden = YES;
        _statusImgv.image = [UIImage imageNamed:@"zhengque.png"];
        [self.contentView addSubview:_statusImgv];
        [_statusImgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_activityIndicator.mas_centerY);
            make.centerX.equalTo(_activityIndicator.mas_centerX);
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
        }];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = HexRGBA(0x404040, 255);
        _nameLabel.font = [UIFont systemFontOfSize:17];
        [self.contentView addSubview:_nameLabel];
        _promitLabel = [[UILabel alloc] init];
        _promitLabel.textColor = HexRGBA(0x666666, 255);
        _promitLabel.font = [UIFont systemFontOfSize:13];
        _promitLabel.numberOfLines = 0;
        [self.contentView addSubview:_promitLabel];
        
        [_promitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_activityIndicator.mas_right).offset(10);
            make.right.equalTo(self.contentView.mas_right).offset(-(15+60));
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
        }];
        
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_activityIndicator.mas_right).offset(10);
            make.right.equalTo(self.contentView.mas_right).offset(-(15+60));
            make.centerY.equalTo(_promitLabel.mas_top).offset(-(44/4.0));
        }];
        
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.textColor = HexRGBA(0x333333, 255);
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.font = [UIFont systemFontOfSize:17];
        [self.contentView addSubview:_statusLabel];
        [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.right.equalTo(self.contentView.mas_right).offset(-15);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(32);
        }];
        _statusLabel.layer.cornerRadius = 3.0;
        _statusLabel.layer.masksToBounds = YES;
        _statusLabel.layer.borderColor = HexRGBA(0x3bb0fc, 255).CGColor;
        _statusLabel.layer.borderWidth = 1.0;
    }
    return self;
}

- (void)connecting {
    self.statusImgv.hidden = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)stopConnectSuccess:(BOOL)connected {
    
    if (connected) {
        self.statusImgv.hidden = NO;
    } else {
        self.statusImgv.hidden = YES;
    }
    
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
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
