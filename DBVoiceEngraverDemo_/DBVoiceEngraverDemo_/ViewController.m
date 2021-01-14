//
//  ViewController.m
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/2.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "ViewController.h"
#import "DBNoiseDetectionVC.h"
#import <DBVoiceEngraver/DBVoiceEngraverManager.h>
#import "UIView+Toast.h"
#import "DBLoginVC.h"
#import <AdSupport/AdSupport.h>

//static  NSString *clientId = @"bb4f7ecb-a4bd-42dd-935a-ba6c64b12f4f";
//static  NSString *clientSecret = @"Zjc3Y2NjOTItZGFkOC00NmVhLWJiZmEtOTkwY2Q0YmNhNzJi";

@interface ViewController ()<DBVoiceDetectionDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearLocalData) name:@"clearLocalData" object:nil];

    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
      NSLog(@"idfa :%@",idfa);
    
    NSString *clientId = [[NSUserDefaults standardUserDefaults] objectForKey:clientIdKey];
    NSString *clientSecret = [[NSUserDefaults standardUserDefaults] objectForKey:clientSecretKey];
    
    if (!clientSecret || !clientId) {
        [self showLogInVC];
        return ;
    }
     
       [[DBVoiceEngraverManager sharedInstance] setupWithClientId:clientId clientSecret:clientSecret queryId:idfa SuccessHandler:^(NSDictionary * _Nonnull dict) {
           [[NSUserDefaults standardUserDefaults]setObject:clientId forKey:clientIdKey];
           [[NSUserDefaults standardUserDefaults]setObject:clientSecret forKey:clientSecretKey];
           [[NSUserDefaults standardUserDefaults] synchronize];
           NSLog(@"获取token成功");
       } failureHander:^(NSError * _Nonnull error) {
           NSLog(@"获取token失败:%@",error);
           [self clearLocalData];
           [self.view makeToast:error.description duration:2.f position:CSToastPositionCenter];
           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               [self showLogInVC];
           });
           
       }];
}

- (void)showLogInVC {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        DBLoginVC *loginVC  =   [story instantiateViewControllerWithIdentifier:@"DBLoginVC"];
    loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:loginVC animated:YES completion:nil];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearLocalData) name:@"clearLocalData" object:nil];
}
- (void)clearLocalData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:clientIdKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:clientSecretKey];
}


// MARK: DBVoiceEngraverDelegate

//- (void)onErrorCode:(NSInteger)errorCode errorMsg:(NSString *)errorMsg {
//    [self.view makeToast:[NSString stringWithFormat:@"%@:%@",@(errorCode),errorMsg] duration:2 position:CSToastPositionCenter];
//}



@end
