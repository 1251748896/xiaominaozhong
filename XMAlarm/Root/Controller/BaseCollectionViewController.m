//
//  BaseCollectionViewController.m
//  Car
//
//  Created by bo.chen on 16/12/8.
//  Copyright © 2016年 com.smaradio. All rights reserved.
//

#import "BaseCollectionViewController.h"

@implementation BaseCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UICollectionView *)contentView {
    if (!_contentView) {
        UICollectionViewFlowLayout *allFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        allFlowLayout.minimumInteritemSpacing = 10;
        allFlowLayout.minimumLineSpacing = 0;
        
        _contentView = [[TPKeyboardAvoidingCollectionView alloc] initWithFrame:CGRectMake(0, GAP20+topBarHeight, deviceWidth, deviceHeight-GAP20-topBarHeight) collectionViewLayout:allFlowLayout];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.dataSource = self;
        _contentView.delegate = self;
        _contentView.alwaysBounceVertical = YES;
        for (Class cls in [self cellClasses]) {
            [_contentView registerClass:cls forCellWithReuseIdentifier:NSStringFromClass(cls)];
        }
    }
    return _contentView;
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeZero;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
