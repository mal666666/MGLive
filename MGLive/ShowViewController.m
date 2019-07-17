//
//  ShowViewController.m
//  Imood
//
//  Created by Mac on 2019/6/28.
//  Copyright © 2019 马 爱林. All rights reserved.
//

#import "ShowViewController.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import <AVFoundation/AVFoundation.h>
@interface ShowViewController ()

@property (nonatomic,strong) IJKFFMoviePlayerController *player;
@property (nonatomic,strong) UIView *bigView;
@property (nonatomic, copy) NSString *urlStr;

@end

@implementation ShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bigView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*352/288)];
    [self.view insertSubview:self.bigView atIndex:0];
    self.bigView.center =CGPointMake(self.bigView.center.x, [UIScreen mainScreen].bounds.size.height/2);
    [self requesetAccessForVideo];
    [self requesetAccessForMedio];
    // 拉流
    self.urlStr =[NSString stringWithFormat:@"rtmp://203.207.99.19:1935/live/%@",self.roomId];
    [self initPlayerObserver];
    [self.player play];
}
/**
 *  请求摄像头资源
 */
- (void)requesetAccessForVideo{
    __weak typeof(self) weakSelf = self;
    //判断授权状态
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            //发起授权请求
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //运行会话
                        //[weakSelf.session setRunning:YES];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            //已授权则继续
            dispatch_async(dispatch_get_main_queue(), ^{
                //[weakSelf.session setRunning:YES];
            });
            break;
        }
        default:
            break;
    }
}

/**
 *  请求音频资源
 */
- (void)requesetAccessForMedio{
    __weak typeof(self) weakSelf = self;
    //判断授权状态
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            //发起授权请求
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //运行会话
                        //[weakSelf.session setRunning:YES];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            //已授权则继续
            dispatch_async(dispatch_get_main_queue(), ^{
                //[weakSelf.session setRunning:YES];
            });
            break;
        }
        default:
            break;
    }
}
- (IBAction)exit:(UIButton *)sender {
    [self.player stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)initPlayerObserver{
    //监听网络状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:) name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.player];
    //监听播放网络状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStateDidChange:) name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
}
//网络状态改变通知响应
- (void)loadStateDidChange:(NSNotification *)notification{
    IJKMPMovieLoadState loadState = self.player.loadState;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"LoadStateDidChange: 可以开始播放的状态: %d\\n",(int)loadState);
    }else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\\n", (int)loadState);
    }
}
//播放状态改变通知响应
- (void)playStateDidChange:(NSNotification *)notification{
    switch (_player.playbackState) {
        case IJKMPMoviePlaybackStateStopped:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        case IJKMPMoviePlaybackStatePlaying:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        case IJKMPMoviePlaybackStatePaused:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        case IJKMPMoviePlaybackStateInterrupted:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}
- (IJKFFMoviePlayerController *)player{
    if(!_player){
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        _player = [[IJKFFMoviePlayerController alloc] initWithContentURLString:self.urlStr withOptions:options];
        _player.scalingMode = IJKMPMovieScalingModeFill;
        _player.view.frame = self.bigView.bounds;
        [self.bigView addSubview:_player.view];
        _player.shouldAutoplay = YES;
        [_player prepareToPlay];
    }
    return _player;
}

@end
