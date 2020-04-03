//
//  DBVoiceDetectionDelegate.h
//  DBVoiceEngraver
//
//  Created by linxi on 2020/3/17.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DBVoiceDetectionDelegate <NSObject>

@optional;

/// 回调当前检测到的音量
/// @param volumeDB 音量
- (void)dbDetecting:(NSInteger)volumeDB;


/// 回调环境检测的结果
/// @param result 1：检测成功 0：检测失败
/// @param volumeDB 检测到的音量
- (void)dbDetectionResult:(BOOL)result value:(NSInteger)volumeDB;


@end

NS_ASSUME_NONNULL_END
