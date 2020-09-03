//
//  CheckAlertView.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "CheckAlertView.h"

#define RowHeight Expand6(40,44)

@interface CheckAlertView ()
<UITableViewDataSource,
UITableViewDelegate>
{
    UITableView *_contentView;
}
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSMutableArray *checkedIndexes;
@property (nonatomic, assign) TwoTitleCellTag cellTag;
@end

@implementation CheckAlertView

- (instancetype)initWithTitle:(NSString *)title dataSource:(NSArray *)dataSource checkedIndexes:(NSArray *)checkedIndexes cellTag:(TwoTitleCellTag)cellTag {
    self = [super initWithFrame:CGRectMake(0, 0, deviceWidth-20, dataSource.count*RowHeight)];
    if (self) {
        self.title = title;
        self.dataSource = dataSource;
        self.checkedIndexes = [NSMutableArray arrayWithArray:checkedIndexes];
        self.cellTag = cellTag;
        
        _contentView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _contentView.backgroundColor = HexGRAY(0xFF, 255);
        _contentView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _contentView.dataSource = self;
        _contentView.delegate = self;
        [_contentView registerClass:[CheckAlertCell class] forCellReuseIdentifier:@"CheckAlertCell"];
        [self addSubview:_contentView];
    }
    return self;
}

- (void)show {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] initWithTitle:self.title];
    alertView.containerView = self;
    alertView.buttonTitles = @[@"取消", @"确定"];
    alertView.delegate = NULL;//为null，不会自动close
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (0 == buttonIndex) {
            [alertView close];
        } else if (1 == buttonIndex) {
            if (self.sureBlock) {
                self.sureBlock(self.checkedIndexes);
            }
            [alertView close];
        }
    }];
    [alertView show];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return RowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CheckAlertCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckAlertCell"];
    BOOL checked = NO;
    NSString *title = self.dataSource[indexPath.row];
    if (TwoTitleCellTag_RiseAlarmSleep == self.cellTag) {
        checked = [[self.checkedIndexes firstObject] integerValue] == indexPath.row;
        title = [NSString stringWithFormat:@"%@分钟", title];
    } else if (TwoTitleCellTag_RiseAlarmPeriod == self.cellTag) {
        if (0 == indexPath.row) {
            checked = self.checkedIndexes.count == 0;
        } else {
            checked = [self.checkedIndexes indexOfObject:[self repeatNumFrom:indexPath]] != NSNotFound;
        }
    }
    cell.dataDict = @{@"title": title, @"checked": @(checked)};
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (TwoTitleCellTag_RiseAlarmSleep == self.cellTag) {
        [self.checkedIndexes removeAllObjects];
        [self.checkedIndexes addObject:@(indexPath.row)];
        [_contentView reloadData];
    } else if (TwoTitleCellTag_RiseAlarmPeriod == self.cellTag) {
        if (0 == indexPath.row && self.checkedIndexes.count == 0) {
            //已选中响铃一次 do nothing
        } else if (0 == indexPath.row) {
            [self.checkedIndexes removeAllObjects];
            [_contentView reloadData];
        } else {
            NSNumber *num = [self repeatNumFrom:indexPath];
            BOOL checked = [self.checkedIndexes indexOfObject:num] != NSNotFound;
            
            if (checked) {
                [self.checkedIndexes removeObject:num];
            } else {
                [self.checkedIndexes addObject:num];
            }
            [_contentView reloadData];
        }
    }
}

- (NSNumber *)repeatNumFrom:(NSIndexPath *)indexPath {
    NSInteger num = indexPath.row+1;
    if (num > 7) {
        num = 1;
    }
    return @(num);
}

@end

@implementation CheckAlertCell {
    UILabel     *_lbl1;
    UIImageView *_checkIcon;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _lbl1 = [[UILabel alloc] init];
        _lbl1.textColor = HexRGBA(0x333333, 255);
        _lbl1.font = [UIFont systemFontOfSize:Expand6(14, 15)];
        [self.contentView addSubview:_lbl1];
        
        _checkIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_choice_nor"]];
        [self.contentView addSubview:_checkIcon];
        
        [_lbl1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.equalTo(_checkIcon.mas_left).mas_offset(-20);
            make.top.height.equalTo(self);
        }];
        [_checkIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(18, 18));
            make.centerY.equalTo(self);
            make.left.equalTo(_lbl1.mas_right).mas_offset(20);
            make.right.equalTo(self).mas_offset(-15);
        }];
        [self.line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.equalTo(self).mas_offset(-15);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}

- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    
    _lbl1.text = dataDict[@"title"];
    BOOL checked = [dataDict[@"checked"] boolValue];
    _checkIcon.image = [UIImage imageNamed:checked ? @"icon_choice_sel" : @"icon_choice_nor"];
}

@end
