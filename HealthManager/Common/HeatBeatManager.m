//
//  HeatBeatManager.m
//  HealthManager
//
//  Created by 赖星果 on 2020/12/25.
//

#import "HeatBeatManager.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "PulseDetector.h"
#import "RateFilter.h"

#define MIN_FRAMES_FOR_FILTER_TO_SETTLE 10

@interface HeatBeatManager ()<AVCaptureVideoDataOutputSampleBufferDelegate>

// 设备
@property (strong, nonatomic) AVCaptureDevice           *device;
// 结合输入输出
@property (strong, nonatomic) AVCaptureSession          *session;
// 输入设备
@property (strong, nonatomic) AVCaptureDeviceInput      *input;
// 输出设备
@property (strong, nonatomic) AVCaptureVideoDataOutput  *output;

@property (nonatomic, strong) PulseDetector             *pulseDetector;

@property (nonatomic, strong) RateFilter                *fiter;
// 采样状态
@property (assign, nonatomic) CurrentStateType          currentState;
// 帧计数器
@property (assign, nonatomic) int                       validFrameCounter;

@end

@implementation HeatBeatManager

+ (HeatBeatManager *)sharedInstance {
    static dispatch_once_t once;
    static HeatBeatManager * __singletion;
    dispatch_once(&once,^{
        __singletion = [[HeatBeatManager alloc] init];
    });
    return __singletion;
}

- (instancetype)init {
    if (self = [super init]) {
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        self.session = [[AVCaptureSession alloc] init];
        self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
        self.output = [[AVCaptureVideoDataOutput alloc] init];
        self.fiter = [[RateFilter alloc] init];
        self.pulseDetector = [[PulseDetector alloc] init];
    }
    return self;
}

#pragma mark - 开始
- (void)start {
    [self setUpCapture];
    [self.session startRunning];
    // 开启闪光灯
    if ([self.device isTorchModeSupported:AVCaptureTorchModeOn]) {
        [self.device lockForConfiguration:nil];
        // 开启闪光灯
        self.device.torchMode=AVCaptureTorchModeOn;
        // 调低闪光灯亮度
        [self.device setTorchModeOnWithLevel:0.1 error:nil];
        [self.device unlockForConfiguration];
    }
}

#pragma mark - 重新检测
- (void)retry {
    [self stop];
    [self start];
}

#pragma mark - 结束
- (void)stop {
    self.currentState = CurrentStateTypePaused;
    self.validFrameCounter = 0;
    [self.pulseDetector reset];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    });
    [self.session stopRunning];
    // 关闭电筒
    if ([self.device isTorchModeSupported:AVCaptureTorchModeOff]) {
        [self.device lockForConfiguration:nil];
        // 关闭电筒
        self.device.torchMode=AVCaptureTorchModeOff;
        [self.device unlockForConfiguration];
    }
}

#pragma mark - 设置摄像头
- (void)setUpCapture {
    //判断相机是否可用
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        NSString *errorStr = @"相机不可用";
        NSError *error = [NSError errorWithDomain:errorStr code:100 userInfo:@{@"content":@"相机不可用,或没有使用相机权限。"}];
        [self stop];
        if ([self.delegate respondsToSelector:@selector(startHeartRateError:)]) {
            [self.delegate startHeartRateError:error];
            return;
        }
    }
    
    // 配置input output
    [self.session beginConfiguration];
    
    // 设置像素输出格式
    NSNumber *BGRA32Format = [NSNumber numberWithInt:kCVPixelFormatType_32BGRA];
    NSDictionary *setting  =@{(id)kCVPixelBufferPixelFormatTypeKey:BGRA32Format};
    [self.output setVideoSettings:setting];
    // 抛弃延迟的帧
    [self.output setAlwaysDiscardsLateVideoFrames:YES];
    //开启摄像头采集图像输出的子线程
    dispatch_queue_t outputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    // 设置子线程执行代理方法
    [self.output setSampleBufferDelegate:self queue:outputQueue];

    // 向session添加
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
#warning 添加这一句 闪光灯就关闭了
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }

    // 降低分辨率，减少采样率
    self.session.sessionPreset = AVCaptureSessionPreset640x480;
    // 设置最小的视频帧输出间隔
    self.device.activeVideoMinFrameDuration = CMTimeMake(1, 10);

    // 用当前的output 初始化connection
    AVCaptureConnection *connection =[self.output connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    // 完成编辑
    [self.session commitConfiguration];
    
    //相机状态
    self.currentState = CurrentStateTypeSampling;
    //停止程序
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    });
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
// captureOutput->当前output   sampleBuffer->样本缓冲   connection->捕获连接
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    //判断停下来不做任和处理
    if(self.currentState == CurrentStateTypePaused) {
        //重置我们的帧计数器
        self.validFrameCounter = 0;
        return;
    }
    
     //判断获取血液波动的值
    if (self.validFrameCounter == 0) {
        NSLog(@"请将手指覆盖住后置摄像头和闪光灯");
        if ([self.delegate respondsToSelector:@selector(startHeartRateTip:)]) {
            [self.delegate startHeartRateTip:@"请将手指覆盖住后置摄像头和闪光灯"];
        }
    }else {
        //得到的数据(可以用来显示进度条或心电图)********
        //NSLog(@"int:%d",self.validFrameCounter);
        NSLog(@"正在获取心率,请不要把手指移开！");
        if ([self.delegate respondsToSelector:@selector(startHeartRateTip:)]) {
            [self.delegate startHeartRateTip:@"正在获取心率,请不要把手指移开！"];
        }
    }
    
    //获取图层缓冲
    CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    uint8_t *buf = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    float r = 0, g = 0,b = 0;
    // 计算RGB
    TORGB(buf, width, height, bytesPerRow, &r, &g, &b);
    //从rgb转换到hsv colourspace
    float h,s,v;
    // RGB转HSV
    RGBtoHSV(r, g, b, &h, &s, &v);
    
    //判断手指是否在摄像头上
    if (s>0.5 && v>0.5) {
        //增加有效的帧数
        self.validFrameCounter++;
        //滤波器色调值,滤波器是一个简单的带通滤波器,消除任何直流分量和高频噪音
        float filtered = [self.fiter processValue:h];
        if(self.validFrameCounter > MIN_FRAMES_FOR_FILTER_TO_SETTLE) {
            //将新值添加到脉冲探测器
            [self.pulseDetector addNewValue:filtered atTime:CACurrentMediaTime()];
            //分析分析瞬时心率
            [self analysisHeartRate];
        }
    }else {
        self.validFrameCounter = 0;
        [self.pulseDetector reset];
        NSLog(@"1111请将手指覆盖住后置摄像头和闪光灯");
        NSString *errStr = @"请将手指覆盖住后置摄像头和闪光灯";
        NSError *err = [NSError errorWithDomain:errStr code:101 userInfo:@{@"content":errStr}];
        if ([self.delegate respondsToSelector:@selector(startHeartRateError:)]) {
            [self.delegate startHeartRateError:err];
        }
    }
}

#pragma mark - 分析瞬时心率
- (void)analysisHeartRate {
    //如果我们停下来然后是无事可做
    if(self.currentState == CurrentStateTypePaused) return;
    //得到的平均周期的脉冲重复频率脉冲探测器
    float avePeriod= [self.pulseDetector getAverage];
    if(avePeriod == INVALID_PULSE_PERIOD) {
        //没有可用的价值 暂不做处理 后期可能会用到
    } else {
        //有值就展示出来
        float pulse = 60.0/avePeriod;
        NSLog(@"瞬时心率:%.2f", pulse);
        if ([self.delegate respondsToSelector:@selector(startHeartRateFrequency:)]) {
            [self.delegate startHeartRateFrequency:(NSInteger)pulse];
        }
    }
}

#pragma mark - 计算RGB
void TORGB (uint8_t *buf, float ww, float hh, size_t pr, float *r, float *g, float *b) {
  
    float wh = (float)(ww * hh );
    for(int y = 0; y < hh; y++) {
        for(int x = 0; x < ww * 4; x += 4) {
            *b += buf[x];
            *g += buf[x+1];
            *r += buf[x+2];
        }
        buf += pr;
    }
    *r /= 255 * wh;
    *g /= 255 * wh;
    *b /= 255 * wh;
}


#pragma mark --- 获取颜色变化的算法
void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v ) {
    float min, max, delta;
    min = MIN( r, MIN(g, b ));
    max = MAX( r, MAX(g, b ));
    *v = max;
    delta = max - min;
    if( max != 0 )
        *s = delta / max;
    else {
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;
    else if( g == max )
        *h = 2 + (b - r) / delta;
    else
        *h = 4 + (r - g) / delta;
    *h *= 60;
    if( *h < 0 )
        *h += 360;
}

@end
