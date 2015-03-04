//
//  ViewController.m
//  nerdtalk-webrtc-ios
//
//  Created by Earl Ferguson (BlueFletch) on 3/3/15.
//  Copyright (c) 2015 BlueFletch. All rights reserved.
//

#import "ViewController.h"
#import "TLKSocketIOSignaling.h"
#import "TLKMediaStreamWrapper.h"
#import "TLKSocketIOSignalingDelegate.h"
#import "RTCVideoRenderer.h"
#import "RTCVideoTrack.h"
#import "RTCVideoRendererDelegate.h"

@interface ViewController ()<TLKSocketIOSignalingDelegate, RTCVideoRendererDelegate>

@property (nonatomic, strong) TLKSocketIOSignaling *signal;
@property (nonatomic, strong) UIView *containerView;

@property (weak, nonatomic) IBOutlet UIView *localVideoView;
@property (weak, nonatomic) IBOutlet UIView *remoteVideoView;

@property (nonatomic, strong) RTCVideoRenderer *localVideoRenderer;
@property (nonatomic, strong) RTCVideoRenderer *remoteVideoRenderer;

@end

@implementation ViewController

NSString *const kRoomNerdTalk = @"nerdtalk";
int const kServerPort = 80;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.signal = [[TLKSocketIOSignaling alloc] initAllowingVideo:YES];
    self.signal.delegate = self;
    
    [self.signal connectToServer:@"signaling.simplewebrtc.com" port:kServerPort secure:NO success:^{
        
        [self join];
        
        NSLog(@"Connection: Successful");
        
    } failure:^(NSError *error) {
        
        NSLog(@"Connection: Failed");
    }];
}

- (void)join {
    
    [self.signal joinRoom:kRoomNerdTalk success:^{
        
        self.localVideoRenderer = [[RTCVideoRenderer alloc] initWithView:self.localVideoView];
        self.localVideoView.layer.transform = CATransform3DMakeScale(1, -1, 1);
        
        [self.signal.localMediaStream.videoTracks[0] addRenderer:self.localVideoRenderer];
        [self.localVideoRenderer start];
        
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.localVideoView.bounds];
        self.localVideoView.layer.masksToBounds = NO;
        self.localVideoView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.localVideoView.layer.shadowRadius = 5.0f;
        self.localVideoView.layer.shadowOffset = CGSizeZero;
        self.localVideoView.layer.shadowOpacity = 0.7f;
        self.localVideoView.layer.shadowPath = shadowPath.CGPath;
        
        NSLog(@"Join: Successful Connection");
        
    } failure:^{
       
        NSLog(@"Join: Failed Connection");
    }];
}

-(void)addedStream:(TLKMediaStreamWrapper*)stream {
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 640, 480)];
    self.containerView.layer.transform = CATransform3DMakeScale(1, -1, 1);
    self.containerView.contentMode = UIViewContentModeCenter;
    
    self.remoteVideoRenderer = [[RTCVideoRenderer alloc] initWithView:self.containerView];
    self.remoteVideoRenderer.delegate = self;
    
    [self.remoteVideoView addSubview:self.containerView];
    [(RTCVideoTrack*)stream.stream.videoTracks[0] addRenderer:self.remoteVideoRenderer];
    [self.remoteVideoRenderer start];
    
    [[self.containerView subviews] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        
        view.contentMode = UIViewContentModeCenter;
    }];
    
}

- (void)videoRenderer:(RTCVideoRenderer *)videoRenderer setSize:(CGSize)size {
    
    NSLog(@"test");
}

- (void)videoRenderer:(RTCVideoRenderer *)videoRenderer renderFrame:(RTCI420Frame *)frame {
    NSLog(@"test");
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
