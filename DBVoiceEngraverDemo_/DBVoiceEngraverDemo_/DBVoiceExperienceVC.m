//
//  DBVoiceExperienceVC.m
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/4.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBVoiceExperienceVC.h"
#import "UIView+Toast.h"
#import <AVFoundation/AVFoundation.h>
#import "XCHudHelper.h"

NSString *const ttsIPURL      = @"https://openapi.data-baker.com/tts_hot_load";

static NSString *textPlaceHolder = @"请输入要合成的文本";

@interface DBVoiceExperienceVC ()<UITextViewDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *playTextView;
@property (weak, nonatomic) IBOutlet UILabel *wordNumLabel;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) AVPlayer * player;
@property(nonatomic,strong)AVPlayerItem * playItem;
@property(nonatomic,strong)NSObject * timeObserve;

@end

@implementation DBVoiceExperienceVC

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.player.rate != 0) {
        [self.player pause];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = [NSString stringWithFormat:@"模型：%@",self.voiceModel.modelId];
    [self p_addPasteActionofView:self.titleLabel];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self addBorderOfView:self.playTextView];
    self.playTextView.text = textPlaceHolder;
    self.wordNumLabel.text = @"字数：0/200";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
   [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self.playButton addTarget:self action:@selector(handlePlayAction:) forControlEvents:UIControlEventTouchUpInside];

}


- (void)appResignActive:(NSNotification *)noti {
    NSLog(@"app 变得不活跃");
    
}
- (void)appBecomeActive:(NSNotification *)noti {
    NSLog(@"app 变活跃");
}
- (IBAction)handlePlayTTSAction:(id)sender {
    [self handlePlayAction:nil];
}



- (void)handlePlayAction:(UIButton *) sender {

    if ([self.playTextView.text isEqualToString:textPlaceHolder]) {
        [self.view makeToast:textPlaceHolder duration:2 position:CSToastPositionCenter];
        return ;
    }
    NSLog(@"1");
    NSURL *url = [self playWithText:self.playTextView.text];
    [self downloadWithUrl:url];
}


- (void)downloadWithUrl:(NSURL *)url {
    
    NSString *filename = @"xxx.mp3";
    //获取 URL
//    NSString *urlStr = [NSString stringWithFormat:@"http://mr7.doubanio.com/832d52e9c3df5c13afd7243a770c094f/0/fm/song/p294_128k.mp3",filename];
//    NSURL *url = [NSURL URLWithString:urlStr];
    //创建请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //创建会话（全局会话）
    NSURLSession *session = [NSURLSession sharedSession];
    //创建任务
    NSURLSessionDownloadTask *downloadTak = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //获取缓存目录
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        //歌存到缓存目录，并命名
        NSString *savePath = [cachePath stringByAppendingPathComponent:filename];
        //得到路径，打开终端 open 去掉 xxx.mp3 的目录，就可以直观的看到 MP3文件的下载
        NSLog(@"%@",savePath);
        
        NSURL *saveurl = [NSURL fileURLWithPath:savePath];
        /*
         1.location 是下载后的临时保存路径，需要将它移动到需要保存的位置
         2.move faster than copy
           (1).因为 copy 需要在磁盘上生成一个新的文件，这个速度是很慢的；
           (2).copy 后，还要把临时文件删除，move 这一步就行了 = (copy + remove)
         3.move 有两个功能 一是移动  二是重命名
         */
        NSError *saveError;
        [[NSFileManager defaultManager]moveItemAtURL:location toURL:saveurl error:&saveError];
        
        //如果错误存在，输出
        if (saveError) {
            NSLog(@"%@",saveError.localizedDescription);
        }
        //播放
        [self playMusic];
    }];
    //执行任务
    [downloadTak resume];
}
-(void)playMusic {
    //获取缓存目录
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    //获取缓存目录下的歌曲
    NSString *filePath = [cachePath stringByAppendingPathComponent:@"xxx.mp3"];
    /*
     fileURLWithPath:  文件链接
     URLWithString:    http链接
     */
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    //判断文件存不存在
    if(
       [[NSFileManager defaultManager]fileExistsAtPath:filePath]){
        NSLog(@"exist");
    
    
        NSError *error;
       [self playWithUrl:fileUrl];
        if (error) {
        NSLog(@"%@",error.localizedDescription);
        }
    //加入缓存
    //播放
    }
}

- (NSURL *)playWithText:(NSString *)playText {
    NSString *accesstoken = [DBVoiceEngraverManager sharedInstance].accessToken;
    NSString * path = [NSString stringWithFormat:@"%@?access_token=%@&domain=1&language=zh&voice_name=%@&text=%@",ttsIPURL,accesstoken,self.voiceModel.modelId,playText];
    NSString *encodeString = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL * url = [NSURL URLWithString:encodeString];
    return url;
}

- (void)downloadURL {
}

- (void)dealloc {
    if (_timeObserve) {
        [_player removeTimeObserver:_timeObserve];
        _timeObserve = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playItem removeObserver:self forKeyPath:@"status"];
}

- (void)playWithUrl:(NSURL *)url {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    self.playItem  = [[AVPlayerItem alloc]initWithURL:url];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playItem];
    self.player = [AVPlayer playerWithPlayerItem:self.playItem];
//     [[XCHudHelper sharedInstance] showHudOnView:self.view caption:@"音频加载中" image:nil acitivity:YES autoHideTime:0];
    NSLog(@"2");

    [self.playItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        [self moniPlayBackAction];
//        [[XCHudHelper sharedInstance] hideHud];
        [self.player play];
        NSLog(@"3");
    }
    
}


- (void)moniPlayBackAction {
    __weak typeof(self)weakSelf = self;
 self.timeObserve =  [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                                queue:NULL
                                                          usingBlock:^(CMTime time) {
     //进度 当前时间/总时间,TTS的音频获取不到音频时间，需要自己估算
//     CGFloat totalTime = CMTimeGetSeconds(weakSelf.playItem.asset.duration);
//     NSLog(@"playerItem :%@",weakSelf.playItem);
     
      CGFloat  totalTime = self.playTextView.text.length *0.265;
     
     CGFloat progress = CMTimeGetSeconds(weakSelf.playItem.currentTime) / totalTime;
     
     NSLog(@"progress : %f  currntTime: %f totalTime %f",progress,CMTimeGetSeconds(weakSelf.playItem.currentTime),CMTimeGetSeconds(weakSelf.playItem.duration));
     weakSelf.progressView.progress = progress;
     weakSelf.playSlider.value = progress;
 }];
}

- (void)videoPlayEnd {
    self.playButton.selected = NO;
    self.playSlider.value = 0;
    self.progressView.progress = 0;
}

- (void)addBorderOfView:(UIView *)view {
    view.layer.borderColor = [UIColor systemBlueColor].CGColor;
    view.layer.borderWidth = 1.f;
    view.layer.masksToBounds =  YES;
}
// MARK: UITextView Methods
-(void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:textPlaceHolder]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
         [self updataTextCountWithTextLength:textView.text.length];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if ([text isEqualToString:@""]) {
        NSInteger textLength = textView.text.length -1;
        if (textLength<0) {
            textLength = 0;
        }
        [self updataTextCountWithTextLength:textLength];
        return YES;
    }
    if (textView.text.length + text.length > 200 ) {
        [self.view makeToast:@"最多输入200个文字" duration:2.f position:CSToastPositionCenter];
        return NO;
    }
    [self updataTextCountWithTextLength:textView.text.length + text.length];
    return YES;
}

- (void)updataTextCountWithTextLength:(NSInteger )textLength {
    NSString *subText = [NSString stringWithFormat:@"%@",@(textLength)];
    NSString *allText = [NSString stringWithFormat:@"字数：%ld/200",(long)textLength];
    NSAttributedString *attributeString = [self setupCountLabelText:allText attributeText:subText];
//    _textCountButton.titleLabel.attributedText = attributeString;
    self.wordNumLabel.attributedText = attributeString;
    
}
- (NSAttributedString *)setupCountLabelText:(NSString *)allText attributeText:(NSString *)attributeText {
    NSRange range = [allText rangeOfString:attributeText];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:allText];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, allText.length)];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor systemBlueColor] range:range];
    return attributeString;
}

// MARK: 私有方法
- (void)p_addPasteActionofView:(UILabel *)label {
    label.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *touch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    touch.numberOfTapsRequired = 1;
    [label addGestureRecognizer:touch];
}
- (void)handleTap:(UILongPressGestureRecognizer *)ges {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *subString = [self.titleLabel.text substringWithRange:NSMakeRange(3, self.titleLabel.text.length-3)];
    
    [pasteboard setString:subString];
    [self.view makeToast:@"复制成功" duration:2 position:CSToastPositionCenter];
}
// MARK: UIResponder Methods

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.playTextView resignFirstResponder];
    [self updataTextCountWithTextLength:self.playTextView.text.length];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
