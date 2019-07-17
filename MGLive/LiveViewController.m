//
//  LiveViewController.m
//  Imood
//
//  Created by Mac on 2019/6/27.
//  Copyright © 2019 马 爱林. All rights reserved.
//

#import "LiveViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "X264Manager.h"
#import "RtmpManager.h"
#import "AudioManager.h"

@interface LiveViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preViewLayer;
@end

@implementation LiveViewController{
    AVCaptureConnection* _videoConnection;
    AVCaptureConnection* _audioConnection;
    RtmpManager* _rtmpManager;
    BOOL _runningFlag;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //推流
    _rtmpManager =[RtmpManager getInstance];
    _rtmpManager.rtmpUrl =[NSString stringWithFormat:@"rtmp://203.207.99.19:1935/live/%@",self.roomId];
    [_rtmpManager startRtmpConnect];
    //音频
    [[AudioManager getInstance]initRecording];
    //视频
    [[X264Manager getInstance] initForX264WithWidth:288 height:352];
    [self setupCaptureSession];
    _runningFlag =YES;
}
- (IBAction)toggleRunning:(UIButton *)sender {
    if (_runningFlag) {
        [self stopRunning];
        [sender setTitle:@"开始" forState:UIControlStateNormal];
    } else {
        [self startRunning];
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
    }
    
    _runningFlag = !_runningFlag;
}
- (IBAction)exitLive:(UIButton *)sender {
    [self stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)setupCaptureSession{
    NSError* error =nil;
    self.session =[[AVCaptureSession alloc]init];
    self.session.sessionPreset =AVCaptureSessionPreset352x288;
    AVCaptureDevice *device =[self cameraWithPosition:AVCaptureDevicePositionFront];
    AVCaptureDeviceInput *input =[AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"error input :%@",error.description);
    }
    if ([_session canAddInput:input]) {
        [_session addInput:input];
    }
    AVCaptureVideoDataOutput *outPut =[[AVCaptureVideoDataOutput alloc]init];
    dispatch_queue_t queue =dispatch_queue_create("myQueue", NULL);
    [outPut setSampleBufferDelegate:self queue:queue];
    outPut.videoSettings =@{(NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]};
    outPut.alwaysDiscardsLateVideoFrames =YES;
    [self startRunning];
    if ([_session canAddOutput:outPut]) {
        [self.session addOutput:outPut];
    }
    [self setSession:self.session];
    _videoConnection =[outPut connectionWithMediaType:AVMediaTypeVideo];
    _videoConnection.videoOrientation =AVCaptureVideoOrientationPortrait;
    self.preViewLayer =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preViewLayer.videoGravity =AVLayerVideoGravityResizeAspectFill;
    self.preViewLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view.layer insertSublayer:self.preViewLayer atIndex:0];
}
// 选择是前摄像头还是后摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}
- (void)startRunning{
    NSLog(@"startRunning");
    [self.session startRunning];
    [[AudioManager getInstance] startRecording];
}
- (void)stopRunning{
    NSLog(@"stopRunning");
    [self.session stopRunning];
    [[AudioManager getInstance] pauseRecording];
}
//捕获帧并编码
-(void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (connection == _videoConnection) {
        [[X264Manager getInstance] encoderToH264:sampleBuffer];
    }
}
@end
