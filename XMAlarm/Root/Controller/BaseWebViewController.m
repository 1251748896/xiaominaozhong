//
//  BaseWebViewController.m
//  Car
//
//  Created by bo.chen on 17/8/10.
//  Copyright © 2017年 com.smaradio. All rights reserved.
//

#import "BaseWebViewController.h"

@interface BaseWebViewController ()

@end

@implementation BaseWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = self.titleStr;
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - view

- (void)setupView {
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, GAP20+topBarHeight, deviceWidth, self.view.height-GAP20-topBarHeight)];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:self.webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.view showLoadingView:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.view hideLoadingView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.view showErrorText:@"加载失败"];
}

@end
