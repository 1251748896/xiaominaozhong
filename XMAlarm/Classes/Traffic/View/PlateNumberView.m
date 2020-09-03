//
//  PlateNumberView.m
//  Car
//
//  Created by bo.chen on 17/4/4.
//  Copyright © 2017年 com.smaradio. All rights reserved.
//

#import "PlateNumberView.h"
#import "ProvinceKeyboardView.h"
#import "KeyInputTextField.h"

@interface PlateNumberView ()
<UITextFieldDelegate,
KeyInputTextFieldDelegate>
{
    UIButton    *_provinceBtn;
    NSMutableArray  *_textFieldArray;
    UIButton    *_saveBtn;
    UIView      *_maskView;
}
@property (nonatomic, strong) NSString *plateNumber;
@property (nonatomic, strong) ProvinceKeyboardView *provinceView;
@end

@implementation PlateNumberView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.didCancelBlock = NULL;
    self.didSaveBlock = NULL;
}

- (instancetype)initWithModel:(NSString *)plateNumber {
    self = [super initWithFrame:CGRectMake(0, 0, 278, 146)];
    if (self) {
        self.plateNumber = plateNumber;
        
        self.backgroundColor = HexGRAY(0xFF, 255);
        _textFieldArray = [NSMutableArray array];
        
        UILabel *lbl = [[UILabel alloc] init];
        lbl.textColor = HexGRAY(0x0, 255);
        lbl.font = [UIFont systemFontOfSize:16];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = @"填写您的车牌号";
        [self addSubview:lbl];
        lbl.frame = CGRectMake(0, 0, self.width, 39);
        
        UIView *line1 = [[UIView alloc] init];
        line1.backgroundColor = HexGRAY(0xE8, 255);
        [self addSubview:line1];
        line1.frame = CGRectMake(0, lbl.height, self.width, 0.5);
        
        _provinceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _provinceBtn.backgroundColor = HexRGBA(0x6181e7, 255);
        [_provinceBtn setTitleColor:HexGRAY(0xFF, 255) forState:UIControlStateNormal];
        _provinceBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        if (self.plateNumber.length > 0) {
            [_provinceBtn setTitle:[self.plateNumber substringWithRange:NSMakeRange(0, 1)] forState:UIControlStateNormal];
        }
        [_provinceBtn setImage:[UIImage imageNamed:@"car_platenumber_down"] forState:UIControlStateNormal];
        [_provinceBtn addTarget:self action:@selector(provinceBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_provinceBtn];
        _provinceBtn.frame = CGRectMake(10, lbl.bottom+16, 49, 34);
        [_provinceBtn layoutButtonWithEdgeInsetsStyle:ButtonEdgeInsetsStyleImageRight imageTitlespace:4];
        
        for (int i = 0; i < 6; i++) {
            KeyInputTextField *textField = [[KeyInputTextField alloc] init];
            textField.delegate = self;
            textField.keyInputDelegate = self;
            textField.backgroundColor = HexRGBA(0xe6e8f0, 255);
            textField.textColor = HexGRAY(0x0, 255);
            textField.font = [UIFont systemFontOfSize:16];
            textField.textAlignment = NSTextAlignmentCenter;
            textField.keyboardType = UIKeyboardTypeASCIICapable;
//            textField.returnKeyType = i == 5 ? UIReturnKeyDone : UIReturnKeyNext;
            textField.returnKeyType = UIReturnKeyDone;
            textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            if (self.plateNumber.length > i+1) {
                textField.text = [self.plateNumber substringWithRange:NSMakeRange(i+1, 1)];
            }
            [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            textField.tag = i;
            [self addSubview:textField];
            textField.frame = CGRectMake(65+(34+1)*i, _provinceBtn.top, 34, 34);
            [_textFieldArray addObject:textField];
        }
        
        UIView *line2 = [[UIView alloc] init];
        line2.backgroundColor = HexGRAY(0xE8, 255);
        [self addSubview:line2];
        line2.frame = CGRectMake(0, 39+66, self.width, 0.5);
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitleColor:HexGRAY(0x0, 255) forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
        cancelBtn.frame = CGRectMake(0, 39+66, self.width/2, 41);
        
        UIView *line3 = [[UIView alloc] init];
        line3.backgroundColor = HexGRAY(0xE8, 255);
        [self addSubview:line3];
        line3.frame = CGRectMake(self.width/2, cancelBtn.top, 0.5, cancelBtn.height);
        
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveBtn setTitleColor:HexRGBA(0x6181e7, 255) forState:UIControlStateNormal];
        [_saveBtn setTitleColor:HexRGBA(0x6181e7, 255*0.5) forState:UIControlStateDisabled];
        _saveBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_saveBtn addTarget:self action:@selector(saveBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_saveBtn];
        _saveBtn.frame = CGRectMake(self.width/2, cancelBtn.top, self.width/2, cancelBtn.height);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [self refreshSaveBtn];
    }
    return self;
}

- (void)show {
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, deviceHeight)];
    _maskView.backgroundColor = HexGRAY(0x0, 255);
    [KEYWindow addSubview:_maskView];
    
    self.left = (deviceWidth-self.width)/2;
    self.top = (deviceHeight-self.height)/2;
    [KEYWindow addSubview:self];
    
    _maskView.alpha = 0.75;
    self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [UIView animateWithDuration:0.25 animations:^{
        _maskView.alpha = 0.5;
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        UITextField *textField = [_textFieldArray firstObject];
        [textField becomeFirstResponder];
    }];
}

- (void)hide {
    [self endEditing:YES];
    [_maskView removeFromSuperview];
    [self removeFromSuperview];
    if (self.provinceView.superview) {
        [self.provinceView removeFromSuperview];
    }
}

- (UITextField *)findNextTextField {
    for (UITextField *textField in _textFieldArray) {
        if (textField.text.length <= 0) {
            return textField;
        }
    }
    return [_textFieldArray firstObject];
}

- (void)refreshSaveBtn {
    BOOL inputAll = YES;
    for (UITextField *textField in _textFieldArray) {
        inputAll = inputAll && (textField.text.length > 0);
    }
    _saveBtn.enabled = inputAll;
}

- (BOOL)charIsValid:(unichar)c forTextField:(UITextField *)textField {
    if (textField.tag == 0) {
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
    if (resultStr.length > 1) {
        if (string.length == 1 && range.location == 1) {
            if ([self charIsValid:[string characterAtIndex:0] forTextField:textField]) {
                textField.text = string;
                [self textFieldDidChange:textField];
            }
        }
        return NO;
    }
    if (resultStr.length == 1) {
        unichar c = [resultStr characterAtIndex:0];
        return [self charIsValid:c forTextField:textField];
    }
    return YES;
}

- (void)deleteBackward:(KeyInputTextField *)textField {
    if (textField.text.length <= 0) {
        UITextField *lastFd = nil;
        for (UITextField *fd in _textFieldArray) {
            if (fd == textField) {
                break;
            }
            lastFd = fd;
        }
        if (lastFd) {            
            lastFd.text = @"";
            [lastFd becomeFirstResponder];
        }
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length > 0) {
        //先变大写
        unichar c = [textField.text characterAtIndex:0];
        if (c >= 'a' && c <= 'z') {
            textField.text = [textField.text uppercaseString];
        }
        //自动跳下一个输入框
        UITextField *nextFd = [self findNextTextField];
        if (nextFd.text.length <= 0) {
            [nextFd becomeFirstResponder];
        }
    }
    [self refreshSaveBtn];
}

- (void)didSelectProvince:(NSString *)str {
    [_provinceBtn setTitle:str forState:UIControlStateNormal];
    //自动跳下一个输入框
    UITextField *nextFd = [self findNextTextField];
    if (nextFd.text.length <= 0) {
        [nextFd becomeFirstResponder];
    }
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
        [self endEditing:YES];
        
        self.provinceView.top = deviceHeight;
        [KEYWindow addSubview:self.provinceView];
        [_provinceBtn setImage:[UIImage imageNamed:@"car_platenumber_up"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.provinceView.top = deviceHeight-self.provinceView.height;
            [self willShowBottomHeight:self.provinceView.height];
        } completion:^(BOOL finished) {
            
        }];
    } else {
//        [[self findNextTextField] becomeFirstResponder];
    }
}

- (void)cancelBtnPressed:(id)sender {
    [self hide];
    if (self.didCancelBlock) {
        self.didCancelBlock();
    }
}

- (void)saveBtnPressed:(id)sender {
    NSMutableString *plateNumber = [NSMutableString stringWithString:_provinceBtn.titleLabel.text];
    for (UITextField *textField in _textFieldArray) {
        [plateNumber appendString:textField.text];
    }
    self.plateNumber = plateNumber;
    
    [self hide];
    if (self.didSaveBlock) {
        self.didSaveBlock(self.plateNumber);
    }
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
            [_provinceBtn setImage:[UIImage imageNamed:@"car_platenumber_down"] forState:UIControlStateNormal];
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
    self.top = MAX(deviceHeight-bottomHeight-self.height-100, 40);
}

@end
