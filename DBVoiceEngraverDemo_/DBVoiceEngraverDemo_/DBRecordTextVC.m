//
//  DBRecordTextVC.m
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/4.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBRecordTextVC.h"
#import <DBVoiceEngraver/DBVoiceEngraverManager.h>
#import "UIViewController+DBBackButtonHandler.h"
#import "UIView+Toast.h"
#import "XCHudHelper.h"
#import "DBRecordCompleteVC.h"

@interface DBRecordTextVC ()<UITextViewDelegate,DBVoiceDetectionDelegate>
@property (weak, nonatomic) IBOutlet UILabel *phaseTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *recordTextView;
@property (weak, nonatomic) IBOutlet UIButton *startRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *finishRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *resumeRecordButton;
@property(nonatomic,strong)DBVoiceEngraverManager * voiceEngraverManager;
@property (weak, nonatomic) IBOutlet UIView *titileBackGroundView;
@property (weak, nonatomic) IBOutlet UILabel *phaseLabel;
@property (weak, nonatomic) IBOutlet UILabel *allPhaseLabel;
@property (weak, nonatomic) IBOutlet UIImageView *voiceImageView;
@property(nonatomic,assign) CFAbsoluteTime startTime;

@property (nonatomic, assign) int index;


@end

@implementation DBRecordTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.index = 0;
    self.view.backgroundColor = [UIColor whiteColor];
    self.voiceEngraverManager =  [DBVoiceEngraverManager sharedInstance];
    self.voiceEngraverManager.delegate= self;
    [self addBoardOfTitleBackgroundView:self.titileBackGroundView cornerRadius:50];
    [self p_setTextViewAttributeText:self.textArray.firstObject];
    self.allPhaseLabel.text = [NSString stringWithFormat:@"共%@段",@(self.textArray.count)];
    #ifdef DBTest
    self.finishRecordButton.hidden = NO;
    #else

    #endif
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}


- (IBAction)startRecordAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.isSelected;
    if (button.isSelected) {
        self.voiceImageView.hidden =  NO;
        self.startTime = CFAbsoluteTimeGetCurrent();
        [self.voiceEngraverManager startRecordWithText:self.recordTextView.text failureHander:^(NSError * _Nonnull error) {
            NSLog(@"error %@",error);
            // 发生错误停止录音
            [self.voiceEngraverManager stopRecord];
        }];
        [self beginRecordState];
        
    }else {
        [self.voiceEngraverManager stopRecord];
        [self endRecordState];
        self.voiceImageView.hidden = YES;
        [self uploadRecoginizeVoice];
    }
}

- (IBAction)finishRecordAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    DBRecordCompleteVC *completedVC  =   [story instantiateViewControllerWithIdentifier:@"DBRecordCompleteVC"];
    [self.navigationController pushViewController:completedVC animated:YES];
    
    return ;
}
- (void)uploadRecoginizeVoice {
    [self showHUD];
    
    [self.voiceEngraverManager uploadRecordVoiceRecogizeHandler:^(DBVoiceRecognizeModel * _Nonnull model) {
        [self hiddenHUD];
        if ([model.status.stringValue isEqualToString:@"1"]) {
            [self.view makeToast:[NSString stringWithFormat:@"上传识别成功：准确率：%@",model.percent] duration:2 position:CSToastPositionCenter];
            self.index++;
            [self nextTextPhaseWithIndex:self.index];
            
        }else {
            [self.view makeToast:[NSString stringWithFormat:@"上传识别失败：准确率：%@",model.percent] duration:2 position:CSToastPositionCenter];
        }
        
    } failureHander:^(NSError * _Nonnull error) {
        [self hiddenHUD];
        [self.view makeToast:@"识别音频失败" duration:2 position:CSToastPositionCenter];
    }];
    
    [self beginRecordState];
}

- (void)nextTextPhaseWithIndex:(NSInteger)phaseIndex {
    
    if (phaseIndex >= self.textArray.count) {
        NSLog(@"最后一段");
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        DBRecordCompleteVC *completedVC  =   [story instantiateViewControllerWithIdentifier:@"DBRecordCompleteVC"];
        [self.navigationController pushViewController:completedVC animated:YES];
    
        return ;
        
    }
    [self p_setTextViewAttributeText:self.textArray[phaseIndex]];
    self.phaseLabel.text =  [NSString stringWithFormat:@"第%@段",@(self.index+1)];
    self.allPhaseLabel.text = [NSString stringWithFormat:@"共%@段",@(self.textArray.count)];

}


- (void)beginRecordState {
    self.resumeRecordButton.hidden = YES;
    self.finishRecordButton.hidden = YES;
    self.startRecordButton.hidden = NO;
}

- (void)endRecordState {
    self.resumeRecordButton.hidden = YES;
    self.finishRecordButton.hidden = YES;
    self.startRecordButton.hidden = NO;
    
}
- (IBAction)resumeRecordAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.isSelected;
    if (button.isSelected) {
        [self.voiceEngraverManager startRecordWithText:self.recordTextView.attributedText.string failureHander:^(NSError * _Nonnull error) {
            NSLog(@"error %@",error);
        }];
        self.resumeRecordButton.hidden = NO;
        self.finishRecordButton.hidden = YES;
        self.startRecordButton.hidden = YES;
    }else {
        [self.voiceEngraverManager stopRecord];
        [self endRecordState];
    }
}
// MARK: delegate Methods -

- (void)onErrorCode:(NSInteger)errorCode errorMsg:(NSString *)errorMsg {
    NSLog(@"error Code %@ ,errorMessage: %@",@(errorCode),errorMsg);
}
- (void)dbDetecting:(NSInteger)volumeDB {
    static NSInteger index = 0;
    index++;
    if (index == 2) {
        index = 0;
    }else {
        return;
    }
        if (volumeDB < 30) {
            self.voiceImageView.image = [UIImage imageNamed:@"1"];
        }else if (volumeDB < 40) {
            self.voiceImageView.image = [UIImage imageNamed:@"2"];

        }else if (volumeDB < 50) {
            self.voiceImageView.image = [UIImage imageNamed:@"3"];

        }else if (volumeDB < 55) {
            self.voiceImageView.image = [UIImage imageNamed:@"4"];

        }else if (volumeDB < 60) {
            self.voiceImageView.image = [UIImage imageNamed:@"5"];

        }else if (volumeDB < 70) {
            self.voiceImageView.image = [UIImage imageNamed:@"6"];

        }else if (volumeDB < 80) {
            self.voiceImageView.image = [UIImage imageNamed:@"7"];

        }else{
            self.voiceImageView.image = [UIImage imageNamed:@"8"];

        }
        self.startTime = CFAbsoluteTimeGetCurrent();
        
//    }
    

}

// MARK: private Method
- (void)p_setTextViewAttributeText:(NSString *)text {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
       paragraphStyle.lineSpacing = 10;// 字体的行间距
        
       NSDictionary *attributes = @{
                                    NSFontAttributeName:[UIFont systemFontOfSize:18],
                                    NSParagraphStyleAttributeName:paragraphStyle
                                    };
       self.recordTextView.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

// MARK: 通过拦截方法获取返回事件
- (BOOL)navigationShouldPopOnBackButton
{
    NSLog(@"clicked navigationbar back button");
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"返回了当前录制结果将会取消？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
           
       }];
    [alertVC addAction:cancelAction];

    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.voiceEngraverManager stopRecord];
        [self.voiceEngraverManager unNormalStopRecordSeesionSuccessHandler:^(NSDictionary * _Nonnull dict) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        } failureHandler:^(NSError * _Nonnull error) {
            [self.view makeToast:@"退出session失败" duration:2 position:CSToastPositionCenter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }];

    }];
    [alertVC addAction:doneAction];
   
    
    [self presentViewController:alertVC animated:YES completion:nil];

    return NO;

}
// MARK: UITextViewDelegate Methods -

- (void)addBoardOfTitleBackgroundView:(UIView *)view  cornerRadius:(CGFloat)cornerRadius {
    view.layer.cornerRadius = cornerRadius;
    [self addBorderOfView:view];
}


// MARK: Pricate Methods -

- (void)showHUD {
    [[XCHudHelper sharedInstance]showHudOnView:self.view caption:@"上传识别中" image:nil
                                     acitivity:YES autoHideTime:30];
}

- (void)hiddenHUD {
    [[XCHudHelper sharedInstance]hideHud];
}
- (void)addBorderOfView:(UIView *)view {
    view.layer.borderColor = [UIColor systemBlueColor].CGColor;
    view.layer.borderWidth = 1.f;
    view.layer.masksToBounds =  YES;
}

- (DBVoiceEngraverManager *)voiceEngraverManager {
    if (!_voiceEngraverManager) {
        _voiceEngraverManager = [DBVoiceEngraverManager sharedInstance];
    }
    return _voiceEngraverManager;
}


@end
