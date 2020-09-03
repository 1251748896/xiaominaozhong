//
//  ModifyPwdViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/29.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "ModifyPwdViewController.h"
#import "AccountInputView.h"

@interface ModifyPwdViewController ()
<UITextFieldDelegate>
{
    AccountInputView    *_pwdView;
    AccountInputView    *_pwd2View;
}
@property (nonatomic, strong) TPKeyboardAvoidingScrollView *contentView;
@end

@implementation ModifyPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"修改密码";
    [self setupView];
}

- (void)setupView {
    self.contentView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, deviceHeight)];
    if (@available(iOS 11.0, *)) {
        self.contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view insertSubview:self.contentView atIndex:0];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 64+20, deviceWidth-40, 35)];
    lbl.textColor = HexRGBA(0x373737, 255);
    lbl.font = [UIFont systemFontOfSize:16];
    lbl.text = @"设置新密码";
    [self.contentView addSubview:lbl];
    
    _pwdView = [[AccountInputView alloc] initWithIconName:@"logins_icon_password" placeholder:@"请设置登录密码(6-16个字符)"];
    _pwdView.frame = CGRectMake(20, lbl.bottom+Expand6(5, 7), deviceWidth-40, 46);
    _pwdView.textFd.keyboardType = UIKeyboardTypeASCIICapable;
    _pwdView.textFd.autocorrectionType = UITextAutocorrectionTypeNo;
    _pwdView.textFd.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _pwdView.objKey = @"password";
    _pwdView.objName = @"密码";
    _pwdView.textFd.secureTextEntry = YES;
    [self.contentView addSubview:_pwdView];
    
    _pwd2View = [[AccountInputView alloc] initWithIconName:@"logins_icon_password" placeholder:@"请再次输入"];
    _pwd2View.frame = CGRectMake(_pwdView.left, _pwdView.bottom+20, _pwdView.width, _pwdView.height);
    _pwd2View.textFd.keyboardType = UIKeyboardTypeASCIICapable;
    _pwd2View.textFd.autocorrectionType = UITextAutocorrectionTypeNo;
    _pwd2View.textFd.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _pwd2View.objKey = @"repassword";
    _pwd2View.objName = @"密码";
    _pwd2View.textFd.secureTextEntry = YES;
    [self.contentView addSubview:_pwd2View];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(20, _pwd2View.bottom+30, deviceWidth-40, 46);
    loginBtn.layer.cornerRadius = 2;
    loginBtn.layer.masksToBounds = YES;
    loginBtn.backgroundColor = HexRGBA(0x248FEC, 255);
    [loginBtn setTitleColor:HexGRAY(0xFF, 255) forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:Expand6(16, 17)];
    [loginBtn setTitle:@"完成" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:loginBtn];
}

- (NSArray *)inputCells {
    return @[_pwdView, _pwd2View];
}

#pragma mark - action

- (void)loginBtnPressed:(id)sender {
    [self.view endEditing:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //检查参数
    for (AccountInputView *fieldObj in self.inputCells) {
        NSString *error = [fieldObj checkValueError];
        if (error.length > 0) {
            [self.view showErrorText:error];
            return;
        }
        [params setValue:fieldObj.textFd.text forKey:fieldObj.objKey];
    }
    
    if (![_pwdView.textFd.text isEqualToString:_pwd2View.textFd.text]) {
        [self.view showErrorText:@"两次输入的密码不一致"];
        return;
    }
    params[@"password"] = [params[@"password"] md5FromString];
    params[@"repassword"] = nil;
    params[@"uid"] = TheUser.id;
    
    [self.view showLoadingView:YES];
    [Api modifyPwd:params successBlock:^(id body) {
        [self.view showSuccessText:@"修改成功"];
        
        TheUser.password = params[@"password"];
        [[UserManager sharedInstance] userDidChange:TheUser];
    } failBlock:^(NSString *message, NSInteger code) {
        [self.view showErrorText:message];
    }];
}

@end
