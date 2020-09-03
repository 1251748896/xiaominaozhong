//
//  ShiftWorkAlertView.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/8.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "ShiftWorkAlertView.h"

#define BottomHeight Expand6(36,42)

@interface ShiftWorkAlertView ()
{
    UIDatePicker    *_picker;
    UIButton        *_restView;
    UIButton        *_workBtn;
    UIButton        *_restBtn;
}
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) ShiftWorkInfo *workInfo;
@end

@implementation ShiftWorkAlertView

- (instancetype)initWithTitle:(NSString *)title workInfo:(ShiftWorkInfo *)workInfo {
    self = [super initWithFrame:CGRectMake(0, 0, deviceWidth-20, 240+BottomHeight)];
    if (self) {
        self.title = title;
        self.workInfo = workInfo;
        
        _picker = [[UIDatePicker alloc] init];
        _picker.datePickerMode = UIDatePickerModeTime;
        _picker.date = self.workInfo.time;
        [self addSubview:_picker];
        
        _restView = [UIButton buttonWithType:UIButtonTypeCustom];
        _restView.frame = CGRectMake(0, 0, self.width, 240);
        _restView.userInteractionEnabled = NO;
        [_restView setTitleColor:HexGRAY(0x99, 255) forState:UIControlStateNormal];
        _restView.titleLabel.font = [UIFont systemFontOfSize:16];
        [_restView setTitle:@"休息中..." forState:UIControlStateNormal];
        [_restView setImage:[UIImage imageNamed:@"shiftalarm_img_resting"] forState:UIControlStateNormal];
        [_restView layoutButtonWithEdgeInsetsStyle:ButtonEdgeInsetsStyleImageTop imageTitlespace:12];
//        _restView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shiftalarm_img_resting"]];
//        _restView.contentMode = UIViewContentModeCenter;
        [self addSubview:_restView];
        
        UIView *btnBg = [[UIView alloc] init];
        btnBg.backgroundColor = HexRGBA(0xF1F2F3, 255);
        [self addSubview:btnBg];
        
        _workBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_workBtn setTitleColor:HexGRAY(0x33, 255) forState:UIControlStateNormal];
        _workBtn.titleLabel.font = [UIFont systemFontOfSize:Expand6(14, 15)];
        [_workBtn setTitle:@"上班" forState:UIControlStateNormal];
        [_workBtn setImage:[UIImage imageNamed:@"icon_choice_nor"] forState:UIControlStateNormal];
        [_workBtn setImage:[UIImage imageNamed:@"icon_choice_sel"] forState:UIControlStateSelected];
        [_workBtn layoutButtonWithEdgeInsetsStyle:ButtonEdgeInsetsStyleImageLeft imageTitlespace:12];
        [_workBtn addTarget:self action:@selector(workBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_workBtn];
        
        _restBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_restBtn setTitleColor:HexGRAY(0x33, 255) forState:UIControlStateNormal];
        _restBtn.titleLabel.font = [UIFont systemFontOfSize:Expand6(14, 15)];
        [_restBtn setTitle:@"休息" forState:UIControlStateNormal];
        [_restBtn setImage:[UIImage imageNamed:@"icon_choice_nor"] forState:UIControlStateNormal];
        [_restBtn setImage:[UIImage imageNamed:@"icon_choice_sel"] forState:UIControlStateSelected];
        [_restBtn layoutButtonWithEdgeInsetsStyle:ButtonEdgeInsetsStyleImageLeft imageTitlespace:12];
        [_restBtn addTarget:self action:@selector(restBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_restBtn];
        
        [_picker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.top.equalTo(self);
            make.bottom.equalTo(self).mas_offset(-BottomHeight);
        }];
        [_restView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_picker);
        }];
        [btnBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.bottom.equalTo(self);
            make.height.mas_equalTo(BottomHeight);
        }];
        [_workBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.height.equalTo(btnBg);
            make.width.equalTo(btnBg.mas_width).multipliedBy(0.5);
        }];
        [_restBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.height.equalTo(btnBg);
            make.width.equalTo(btnBg.mas_width).multipliedBy(0.5);
        }];
        
        [self refreshView];
    }
    return self;
}

- (void)workBtnPressed:(id)sender {
    if (_workBtn.selected) {
        return;
    }
    self.workInfo.needWork = @YES;
    [self refreshView];
}

- (void)restBtnPressed:(id)sender {
    if (_restBtn.selected) {
        return;
    }
    self.workInfo.needWork = @NO;
    [self refreshView];
}

- (void)refreshView {
    _workBtn.selected = self.workInfo.needWork.boolValue;
    _restBtn.selected = !_workBtn.selected;
    _picker.hidden = _restBtn.selected;
    _restView.hidden = !_picker.hidden;
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
                self.workInfo.time = _picker.date;
                self.sureBlock(self.workInfo);
            }
            [alertView close];
        }
    }];
    [alertView show];
}

@end
