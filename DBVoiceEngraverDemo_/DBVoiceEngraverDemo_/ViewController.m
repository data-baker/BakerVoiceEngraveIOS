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

@interface ViewController ()<DBVoiceDetectionDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *clientId = [[NSUserDefaults standardUserDefaults] objectForKey:clientIdKey];
    NSString *clientSecret = [[NSUserDefaults standardUserDefaults] objectForKey:clientSecretKey];
    
    if (!clientSecret || !clientId) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            DBLoginVC *loginVC  =   [story instantiateViewControllerWithIdentifier:@"DBLoginVC"];
        loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:loginVC animated:YES completion:nil];
        return ;
    }
    
       [[DBVoiceEngraverManager sharedInstance] setupWithClientId:clientId clientSecret:clientSecret queryId:@"9162"SuccessHandler:^(NSDictionary * _Nonnull dict) {
           [[NSUserDefaults standardUserDefaults]setObject:clientId forKey:clientIdKey];
           [[NSUserDefaults standardUserDefaults]setObject:clientSecret forKey:clientSecretKey];
           [[NSUserDefaults standardUserDefaults] synchronize];
           NSLog(@"获取token成功");
       } failureHander:^(NSError * _Nonnull error) {
           NSLog(@"获取token失败:%@",error);
           
       }];

}

// MARK: DBVoiceEngraverDelegate

//- (void)onErrorCode:(NSInteger)errorCode errorMsg:(NSString *)errorMsg {
//    [self.view makeToast:[NSString stringWithFormat:@"%@:%@",@(errorCode),errorMsg] duration:2 position:CSToastPositionCenter];
//}



@end
