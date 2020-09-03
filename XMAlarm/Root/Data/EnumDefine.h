//
//  EnumDefine.h
//  VoiceBox
//
//  Created by Mac on 16/5/12.
//  Copyright © 2016年 helfy. All rights reserved.
//

#ifndef EnumDefine_h
#define EnumDefine_h

typedef NS_ENUM(NSInteger, DownloadState) {
    DownloadState_None = 0,        //
    DownloadState_Wait = 1, //等待下载
    DownloadState_Downloading = 2,  //正在下载
    DownloadState_Finish = 3,   //下载完成
    DownloadState_Error = 4,    //下载出错
};

typedef NS_ENUM(NSInteger, TwoTitleCellTag) {
    TwoTitleCellTag_Name = 1,
    TwoTitleCellTag_RiseAlarmPeriod = 2,
    TwoTitleCellTag_RiseAlarmSleep = 3,
    TwoTitleCellTag_RingName = 4,
    TwoTitleCellTag_CustomAlarmDate = 5,
    TwoTitleCellTag_ShiftAlarmPeriod = 6,
    TwoTitleCellTag_TempRemindTime = 7,
    TwoTitleCellTag_RepeatRemindTime = 8,
    TwoTitleCellTag_City = 9,
    TwoTitleCellTag_PlateNumber = 10,
    TwoTitleCellTag_RemindSetting = 11,
    TwoTitleCellTag_SwitchSyncAlarm = 12,
    TwoTitleCellTag_TimeAfterAlarm = 13,
    TwoTitleCellTag_SwitchLimitRemind = 14,
    TwoTitleCellTag_yearCheckDate = 15,
};

typedef NS_ENUM(NSInteger, AppNotiType) {
    AppNotiType_RiseAlarm = 1,
    AppNotiType_ShiftAlarm = 2,
    AppNotiType_CustomAlarm = 3,
    AppNotiType_TempRemind = 4,
    AppNotiType_RepeatRemind = 5,
    AppNotiType_Traffic = 6,
};

#endif /* EnumDefine_h */
