//
//  PlateNumber2ViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/10/29.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "PlateNumber2ViewController.h"
#import "ProvinceKeyboardView.h"
#import "KeyInputTextField.h"
#import "SelectCityViewController.h"
#import "TrafficLimitViewController.h"

#import "DriveCardDateViewController.h"
#import "CityRuleTools.h"



@interface PlateNumber2ViewController ()
<UITextFieldDelegate,
KeyInputTextFieldDelegate>
{
    UIButton    *_provinceBtn;
    UIImageView *_arrowView;
    KeyInputTextField   *_numFd;
}
@property (nonatomic, strong) NSString *plateNumber;
@property (nonatomic, strong) ProvinceKeyboardView *provinceView;
@end

@implementation PlateNumber2ViewController

- (instancetype)initWithPlateNumber:(NSString *)plateNumber {
    self = [super init];
    if (self) {
        self.plateNumber = plateNumber;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"车牌号";
    [self customRightTextBtn:@"确定" action:@selector(sureBtnPressed:)];
    [self setupView];
}

- (void)setupView {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, GAP20+topBarHeight+140, deviceWidth, 39)];
    lbl.textColor = HexRGBA(0x373737, 255);
    lbl.font = [UIFont systemFontOfSize:Expand6(16, 17)];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = @"请输入限行车牌号";
    [self.view addSubview:lbl];
    
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_platenumber"]];
    bgView.userInteractionEnabled = YES;
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(bgView.image.size);
        make.centerX.equalTo(self.view);
        make.top.equalTo(lbl.mas_bottom).mas_offset(16);
    }];
    
    _provinceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_provinceBtn setTitleColor:HexGRAY(0xFF, 255) forState:UIControlStateNormal];
    _provinceBtn.titleLabel.font = [UIFont systemFontOfSize:26];
    if (self.plateNumber.length > 0) {
        [_provinceBtn setTitle:[self.plateNumber substringWithRange:NSMakeRange(0, 1)] forState:UIControlStateNormal];
    }
    [_provinceBtn addTarget:self action:@selector(provinceBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:_provinceBtn];
    [_provinceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.height.equalTo(bgView);
        make.width.mas_equalTo(55);
    }];
    
    _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plate_icon_dropdown"]];
    [bgView addSubview:_arrowView];
    [_arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(_arrowView.image.size);
        make.centerY.equalTo(bgView);
        make.left.equalTo(_provinceBtn.mas_right).mas_offset(-4);
    }];
    
    _numFd = [[KeyInputTextField alloc] init];
    _numFd.delegate = self;
    _numFd.keyInputDelegate = self;
    _numFd.textColor = HexGRAY(0xFF, 255);
    _numFd.font = [UIFont systemFontOfSize:26];
    _numFd.textAlignment = NSTextAlignmentCenter;
    _numFd.keyboardType = UIKeyboardTypeASCIICapable;
    _numFd.autocapitalizationType = UITextAutocapitalizationTypeWords;
    _numFd.autocorrectionType = UITextAutocorrectionTypeNo;
    if (self.plateNumber.length > 1) {
        _numFd.text = [self.plateNumber substringWithRange:NSMakeRange(1, self.plateNumber.length-1)];
    }
    [_numFd addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [bgView addSubview:_numFd];
    [_numFd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.right.equalTo(bgView);
        make.left.equalTo(_arrowView.mas_right).mas_offset(4);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    if (_provinceBtn.titleLabel.text.length <= 0) {
        [self provinceBtnPressed:_provinceBtn];
    } else {
        [_numFd becomeFirstResponder];
    }
}

- (BOOL)checkInputAll {
    return _numFd.text.length == 6 && _provinceBtn.titleLabel.text.length > 0;
}

- (BOOL)charIsValid:(unichar)c forPosition:(NSInteger)pos {
    if (pos == 0) {
        if (!(c >= 'a' && c <= 'z') && !(c >= 'A' && c <= 'Z')) {
            return NO;
        }
    } else {
        if (!(c >= 'a' && c <= 'z') && !(c >= 'A' && c <= 'Z') && !(c >= '0' && c <= '9')) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *resultStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (resultStr.length > 6) {
        return NO;
    }
    for (NSInteger i = 0; i < resultStr.length; i++) {
        unichar c = [resultStr characterAtIndex:i];
        if (![self charIsValid:c forPosition:i]) {
            return NO;
        }
    }
    return YES;
}

- (void)deleteBackward:(KeyInputTextField *)textField {
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length > 0) {
        //变大写
        textField.text = [textField.text uppercaseString];
    }
}

- (void)didSelectProvince:(NSString *)str {
    [_provinceBtn setTitle:str forState:UIControlStateNormal];
    //自动跳下一个输入框
    [_numFd becomeFirstResponder];
}

#pragma mark - action

- (void)provinceBtnPressed:(id)sender {
    if (!self.provinceView) {
        self.provinceView = [[ProvinceKeyboardView alloc] initWithProvince:_provinceBtn.titleLabel.text];
        WeakSelf
        self.provinceView.didSelectBlock = ^(NSString *provinceStr) {
            [weakSelf didSelectProvince:provinceStr];
        };
    }
    if (!self.provinceView.superview) {
        //触发显示选择省视图
        [self.view endEditing:YES];
        
        self.provinceView.top = deviceHeight;
        [self.view addSubview:self.provinceView];
//        [_provinceBtn setImage:[UIImage imageNamed:@"car_platenumber_up"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.provinceView.top = deviceHeight-self.provinceView.height;
            [self willShowBottomHeight:self.provinceView.height];
        } completion:^(BOOL finished) {
            
        }];
    } else {
//        [[self findNextTextField] becomeFirstResponder];
    }
}

- (void)sureBtnPressed:(id)sender {
    if (![self checkInputAll]) {
        [self.view showWarningText:@"请输入完整的车牌号"];
        return;
    }
    [_numFd resignFirstResponder];
    //  账号
    NSMutableString *plateNumber = [NSMutableString stringWithString:_provinceBtn.titleLabel.text];
    [plateNumber appendString:_numFd.text];
    self.plateNumber = plateNumber;
    
    [self doneSureBlock];
}

- (void)doneSureBlock {
    WeakSelf
    //新的车牌号
    self.alarm.plateNumber = self.plateNumber;
    
    [CityRuleTools showDetailInfo:self.alarm finish:^(int state) {
        StrongObj(weakSelf)
        [strongweakSelf handleNotification:state];
        strongweakSelf.alarm.showState = [NSNumber numberWithInt:state];
        if (strongweakSelf.initAdd) {
            strongweakSelf.alarm.plateNumber = strongweakSelf.plateNumber;
            DriveCardDateViewController *vc = [[DriveCardDateViewController alloc] init];
            vc.alarm = strongweakSelf.alarm;
            vc.initAdd = strongweakSelf.initAdd;
            vc.showState = state;
            [strongweakSelf.navigationController pushViewController:vc animated:YES];
        } else {
            if (strongweakSelf.sureBlock) {
                strongweakSelf.sureBlock(strongweakSelf.plateNumber);
            } else if (strongweakSelf.fixCity) {
                strongweakSelf.fixCity(strongweakSelf.plateNumber, state);
            }
            [strongweakSelf backBtnPressed:nil];
        }
    }];
    
}

- (void)removeNotice {
    [self.alarm deleteNotification:YES];
    [self.alarm remove];
}

- (void)handleNotification:(int)sta {
    if (sta == 10 || sta == 11) {
        [self removeNotice];
    } else {
        [self.alarm resetRemindSettings];
    }
}

- (void)jumpInputCity:(NSString *)warningText {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:warningText cancelButtonTitle:@"确定"];
    [alertView showUsingBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (self.initAdd) {
            [self doneSureBlock];
//            [self.navigationController popViewControllerAnimated:YES];
        } else {
            SelectCityViewController *controller = [[SelectCityViewController alloc] init];
            controller.alarm = self.alarm;
            controller.sureBlock = ^() {
                if (self.sureBlock) {
                    self.sureBlock(@"");
                }
            };
            [self.navigationController replaceLastViewController:controller animated:YES];
        }
    }];
}

#pragma mark - move

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame {
    if (beginFrame.origin.y == deviceHeight) {
        //显示键盘
        [self willShowBottomHeight:toFrame.size.height];
        if (self.provinceView.superview) {
            [self.provinceView removeFromSuperview];
//            [_provinceBtn setImage:[UIImage imageNamed:@"car_platenumber_down"] forState:UIControlStateNormal];
        }
    }
    else if (toFrame.origin.y == deviceHeight) {
        [self willShowBottomHeight:0];
    }
    else {
        [self willShowBottomHeight:toFrame.size.height];
    }
}

- (void)willShowBottomHeight:(CGFloat)bottomHeight {
//    self.top = MAX(deviceHeight-bottomHeight-self.height-100, 40);
}

@end
