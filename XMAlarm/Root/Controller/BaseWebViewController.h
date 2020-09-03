//
//  BaseWebViewController.h
//  Car
//
//  Created by bo.chen on 17/8/10.
//  Copyright © 2017年 com.smaradio. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseWebViewController : BaseViewController
<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, copy) NSString *titleStr;
@end
