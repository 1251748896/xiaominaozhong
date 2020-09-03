//
//  ProvinceKeyboardView.m
//  Car
//
//  Created by bo.chen on 17/4/4.
//  Copyright © 2017年 com.smaradio. All rights reserved.
//

#import "ProvinceKeyboardView.h"

@interface ProvinceKeyboardView ()
<UICollectionViewDataSource,
UICollectionViewDelegate>
{
    UICollectionView    *_collectionView;
    NSArray     *_dataSource;
}
@property (nonatomic, copy) NSString *selectedProvince;
@end

@implementation ProvinceKeyboardView

- (void)dealloc {
    self.didSelectBlock = NULL;
}

- (instancetype)initWithProvince:(NSString *)provinceStr {
    self = [super initWithFrame:CGRectMake(0, 0, deviceWidth, (4+45+4)*4+BottomGap)];
    if (self) {
        self.selectedProvince = provinceStr;
        self.backgroundColor = HexRGBA(0xd1d6db, 255);
        
        UICollectionViewFlowLayout *allFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        allFlowLayout.minimumInteritemSpacing = 0;
        allFlowLayout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height-BottomGap) collectionViewLayout:allFlowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[ProvinceKeyboardCell class] forCellWithReuseIdentifier:@"ProvinceKeyboardCell"];
        [self addSubview:_collectionView];
        
        _dataSource = @[@"京", @"津", @"沪", @"渝", @"冀", @"晋", @"辽", @"吉", @"黑",
                        @"苏", @"浙", @"皖", @"闽", @"赣", @"鲁", @"豫", @"鄂", @"湘",
                        @"粤", @"琼", @"川", @"贵", @"云", @"陕", @"甘", @"青", @"桂",
                        @"蒙", @"藏", @"宁", @"新"];
    }
    return self;
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = floor(deviceWidth/9);
    return CGSizeMake(width, 4+45+4);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProvinceKeyboardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProvinceKeyboardCell" forIndexPath:indexPath];
    NSString *title = _dataSource[indexPath.row];
    [cell.btn setTitle:title forState:UIControlStateNormal];
    cell.btn.selected = [title isEqualToString:self.selectedProvince];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSString *title = _dataSource[indexPath.row];
    self.selectedProvince = title;
    [_collectionView reloadData];
    
    if (self.didSelectBlock) {
        self.didSelectBlock(title);
    }
}

@end

@implementation ProvinceKeyboardCell {
    UIButton    *_btn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.backgroundColor = HexGRAY(0xFF, 255);
        [_btn setTitleColor:HexGRAY(0x0, 255) forState:UIControlStateNormal];
        [_btn setTitleColor:HexRGBA(0x6181e7, 255) forState:UIControlStateSelected];
        _btn.userInteractionEnabled = NO;
        [self.contentView addSubview:_btn];
        [_btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(4, 4, 4, 4));
        }];
    }
    return self;
}

@end
