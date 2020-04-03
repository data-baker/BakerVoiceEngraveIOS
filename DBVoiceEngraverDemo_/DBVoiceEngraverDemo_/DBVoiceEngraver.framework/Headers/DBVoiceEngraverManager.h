//
//  DBVoiceCopyManager.h
//  DBVoiceCopyFramework
//
//  Created by linxi on 2020/3/3.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBVoiceModel.h"
#import "DBVoiceDetectionDelegate.h"


NS_ASSUME_NONNULL_BEGIN

typedef void (^DBSuccessHandler)(NSDictionary *dict);
///  上传识别回调的block
typedef void (^DBVoiceRecogizeHandler)(DBVoiceRecognizeModel *model);
/// 获取识别文本的block
typedef void (^DBTextBlock)(NSArray <NSString *> *textArray);
/// 获取声音模型的block
typedef void (^DBSuccessModelHandler)(NSArray<DBVoiceModel *> *array);

typedef void (^DBSuccessOneModelHandler)(DBVoiceModel  *voiceModel);

/// 失败的回调
typedef void (^DBFailureHandler)(NSError *error);





@interface DBVoiceEngraverManager : NSObject

@property(nonatomic,weak)id<DBVoiceDetectionDelegate>  delegate;

@property(nonatomic,copy,readonly)NSString * accessToken;

/// 默认为NO，开启Yes可打印log日志
@property(nonatomic,assign)BOOL  enableLog;


// 实例化对象
+ (instancetype )sharedInstance;

/// 初始化SDK，使用分配的clientiD，ClientSecret,其中querId为选填项
/// @param clientId ID
/// @param clientSecret secret
/// @param queryId 查询Id，选填项
/// @param successHandler 成功回调
/// @param failureHandler 失败回调
- (void)setupWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret queryId:(nullable NSString * )queryId SuccessHandler:(DBSuccessHandler)successHandler failureHander:(DBFailureHandler)failureHandler;


- (void)getRecordTextArrayTextHandler:(DBTextBlock)textHandler failure:(DBFailureHandler)failureHandler;

/// 获取当前Id需要的录音剩余Id
//- (void)getRecordLimitSuccessHandler:(DBSuccessHandler)successHandler failureHander:(DBFailureHandler)failureHandler;


/// 设置查询Id，需要在执行获取sessionId前设置，此参数不是必填参数，但是强烈建议使用
/// @param queryId 查询Id
- (void)setupQueryId:(nullable NSString *)queryId;

// 开始录音，第一次录音会开启一个会话session,如果开启失败会通过failureHandler回调错误
- (void)startRecordWithText:(NSString *)text failureHander:(DBFailureHandler)failureHandler;

// 结束录音
- (void)stopRecord;

// 非正常录音结束
- (void)unNormalStopRecordSeesionSuccessHandler:(DBSuccessHandler)successBlock failureHandler:(DBFailureHandler)failureHandler;

/// 上传录音的声音到服务器
/// @param successHandler 上传成功的回调
/// @param failureHandler 上传失败的回调
- (void)uploadRecordVoiceRecogizeHandler:(DBVoiceRecogizeHandler)successHandler failureHander:(DBFailureHandler)failureHandler;

/// 查询模型状态
- (void)queryModelStatusByModelId:(NSString *)modelId SuccessHandler:(DBSuccessOneModelHandler)successHandler failureHander:(DBFailureHandler)failureHandler;

/// 批量查询模型状态
- (void)batchQueryModelStatusByQueryId:(NSString *_Nullable)queryId SuccessHandler:(DBSuccessModelHandler)successHandler failureHander:(DBFailureHandler)failureHandler;


/// 开启模型训练
- (void)startModelTrainRecordVoiceWithPhoneNumber:(NSString * _Nullable)phoneNumber
                                        notifyUrl:(NSString *_Nullable)notifyUrl
                                   successHandler:(DBSuccessOneModelHandler)successHandler
                                    failureHander:(DBFailureHandler)failureHandler;


@end

NS_ASSUME_NONNULL_END
