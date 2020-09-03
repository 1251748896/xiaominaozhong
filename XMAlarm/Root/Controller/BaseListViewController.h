//
//  BaseListViewController.h
//  Car
//
//  Created by bo.chen on 16/12/23.
//  Copyright © 2016年 com.smaradio. All rights reserved.
//

#import "BaseViewController.h"
#import "ODRefreshControl.h"
#import "PullMoreView.h"

@interface BaseListViewController : BaseViewController
<PullMoreViewDelegate>
{
    NSMutableArray  *_dataSource;
    ODRefreshControl    *_header;
    PullMoreView    *_footer;
    NSInteger       _page;
    BOOL            _shouldEnd;
    AFHTTPRequestOperation  *_connection;
    UIView          *_emptyView;
}
@property (nonatomic, readonly) UITableView *contentView;
@property (nonatomic, readonly) NSMutableArray *dataSource;
@property (nonatomic, readonly) ODRefreshControl *header;
@property (nonatomic, readonly) UIView *emptyView;
- (NSArray *)cellClasses;
- (void)dataFactory;
- (NSInteger)startIndex;
- (void)addHeader;
- (void)removeHeader;
- (void)addFooter;
- (void)removeFooter;
- (void)cancelConnection;
- (void)headerRefreshData:(ODRefreshControl *)header;
- (void)requestData;
- (void)handleData:(NSArray *)body;
- (BOOL)shouldEndData:(NSArray *)body;
- (void)handleError:(NSString *)msg;
- (BOOL)shouldParseDataModel;
- (id)parseDataModel:(NSDictionary *)dict;
- (BOOL)needEmptyView;
- (void)refreshView;
@end
