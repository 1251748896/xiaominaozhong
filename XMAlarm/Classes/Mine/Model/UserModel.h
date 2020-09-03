//
//  UserModel.h
//  Car
//
//  Created by bo.chen on 16/12/5.
//  Copyright © 2016年 com.smaradio. All rights reserved.
//

#import "BaseModel.h"

@interface UserModel : BaseModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSNumber *createTime;
@property (nonatomic, strong) NSNumber *updateTime;//毫秒
@property (nonatomic, strong) NSString *status;//"ACTIVE" "DEL"
@property (nonatomic, strong) NSString *mobile;//手机号
@property (nonatomic, strong) NSString *password;//md5的字符串
@property (nonatomic, strong) NSString *userName;//用户名 默认手机号
@property (nonatomic, strong) NSString *avatar;//头像

- (NSString *)avatarUrlString;

@end
