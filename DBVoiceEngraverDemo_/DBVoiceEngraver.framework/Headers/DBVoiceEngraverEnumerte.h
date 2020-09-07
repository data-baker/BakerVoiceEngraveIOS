//
//  DBVoiceCopyEnumerte.h
//  DBVoiceCopyFramework
//
//  Created by linxi on 2020/3/3.
//  Copyright © 2020 biaobei. All rights reserved.
//

#ifndef DBVoiceEngraverEnumerte_h
#define DBVoiceEngraverEnumerte_h

typedef NS_ENUM(NSUInteger,DBErrorState){
    DBErrorStateNOError                  = 0,// 成功，没有发生错误
    DBErrorStateMircrophoneNotPermission = 1000, // 麦克风没有权限
    DBErrorStateInitlizeSDK              = 1001, // 初始化SDK失败
    DBErrorStateFailureToAccessToken     = 1002, // 获取token失败
    DBErrorStateFailureToGetSession      = 1003, // 获取session失败
    DBErrorStateFailureInvalidParams      = 1004, // 无效的参数
    DBErrorStateNetworkDataError          = 99999,// 获取网络数据错误
};


#endif /* DBVoiceCopyEnumerte_h */
