//
//  BaseTableViewCell.m
//  shareKouXiaoHai
//
//  Created by bo.chen on 16/12/3.
//  Copyright © 2016年 Kouxiaoer. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (void)dealloc {
//    DEBUG_LOG(@"%@", NSStringFromClass(self.class));
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        _line = [[UIView alloc] init];
        _line.backgroundColor = HexGRAY(0xE3, 255);
        [self.contentView addSubview:_line];
        [_line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.height.equalTo(@0.5);
        }];
    }
    return self;
}

@end
