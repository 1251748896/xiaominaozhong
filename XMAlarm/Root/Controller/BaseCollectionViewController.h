//
//  BaseCollectionViewController.h
//  Car
//
//  Created by bo.chen on 16/12/8.
//  Copyright © 2016年 com.smaradio. All rights reserved.
//

#import "BaseListViewController.h"

@interface BaseCollectionViewController : BaseListViewController
<UICollectionViewDataSource,
UICollectionViewDelegate>
{
    TPKeyboardAvoidingCollectionView *_contentView;
}
@end
