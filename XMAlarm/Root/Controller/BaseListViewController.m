//
//  BaseListViewController.m
//  Car
//
//  Created by bo.chen on 16/12/23.
//  Copyright © 2016年 com.smaradio. All rights reserved.
//

#import "BaseListViewController.h"

@implementation BaseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _page = [self startIndex];
    _shouldEnd = NO;
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    if (@available(iOS 11.0, *)) {
        self.contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view insertSubview:self.contentView atIndex:0];
}

- (void)backBtnPressed:(id)sender {
    [self cancelConnection];
    [super backBtnPressed:sender];
}

- (void)scrollToTop:(BOOL)enabled {
    self.contentView.scrollEnabled = enabled;
}

#pragma mark - override

- (NSArray *)cellClasses {
    return @[];
}

- (void)dataFactory {
    
}

- (NSInteger)startIndex {
    return 1;
}

- (void)addHeader {
    if (!_header) {
        _header = [[ODRefreshControl alloc] initInScrollView:self.contentView];
        _header.activityIndicatorViewColor = BTNACTIVECOLOR;
        [_header addTarget:self action:@selector(headerRefreshData:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)removeHeader {
    if (_header) {
        [_header removeFromSuperview];
        _header = nil;
    }
}

- (void)addFooter {
    if (!_footer) {
        _footer = [[PullMoreView alloc] initInScrollView:self.contentView];
        _footer.delegate = self;
    }
}

- (void)removeFooter {
    if (_footer) {
        [_footer removeFromSuperview];
        _footer = nil;
    }
}

- (void)cancelConnection {
    if (_connection) {
        [_connection clearBlockAndCancel];
        _connection = nil;
    }
}

- (void)headerRefreshData:(ODRefreshControl *)header {
    _page = [self startIndex];
    [self requestData];
}

- (void)pullMoreViewStartLoadingData:(PullMoreView *)view {
    _page++;
    [self requestData];
}

- (void)requestData {
}

- (void)handleData:(NSArray *)body {
    _connection = nil;
    if ([self startIndex] == _page) {
        [_header endRefreshing];
        [_dataSource removeAllObjects];
    }
    if ([self shouldParseDataModel]) {
        for (NSDictionary *dict in body) {
            id obj = [self parseDataModel:dict];
            if (obj) {
                [_dataSource addObject:obj];
            }
        }
    } else {
        [_dataSource addObjectsFromArray:body];
    }
    [self refreshView];
    
    [_footer endLoading];
    if ([self shouldEndData:body]) {
        [_footer removeFromSuperview];
        _footer = nil;
    } else {
        [self addFooter];
    }
}

- (BOOL)shouldEndData:(NSArray *)body {
    return _shouldEnd || body.count == 0;
}

- (void)handleError:(NSString *)msg {
    _connection = nil;
    [self.view showErrorText:msg];
    [_header endRefreshing];
    [_footer endLoading];
}

- (BOOL)shouldParseDataModel {
    return NO;
}

- (id)parseDataModel:(NSDictionary *)dict {
    return nil;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _emptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 290, 30)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = HexGRAY(0x2E, 255);
        lbl.font = [UIFont systemFontOfSize:16];
        lbl.text = @"暂无内容";
        [_emptyView addSubview:lbl];
    }
    return _emptyView;
}

- (BOOL)needEmptyView {
    return YES;
}

- (void)refreshView {
    [self.contentView reloadData];
    if ([self needEmptyView]) {
        if (self.dataSource.count <= 0) {
            if (!self.emptyView.superview) {
                [self.contentView addSubview:self.emptyView];
            }
        } else {
            [self.emptyView removeFromSuperview];
        }
    } else {
        [self.emptyView removeFromSuperview];
    }
}

@end
