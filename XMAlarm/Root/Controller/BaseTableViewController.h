//
//  BaseTableViewController.h
//  shareKouXiaoHai
//
//  Created by bo.chen on 16/2/22.
//  Copyright © 2016年 Kouxiaoer. All rights reserved.
//

#import "BaseListViewController.h"

@interface BaseTableViewController : BaseListViewController
<UITableViewDataSource,
UITableViewDelegate>
{
    TPKeyboardAvoidingTableView *_contentView;
}
- (UITableViewStyle)tableViewStyle;
@end
