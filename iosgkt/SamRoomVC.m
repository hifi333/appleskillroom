

//
//  SamRoomVC.m
//  OpenVideoCall
//
//  Created by sam.zhang on 2018/6/14.
//  Copyright © 2018年 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SamRoomVC.h"

#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import <AgoraRtcCryptoLoader/AgoraRtcCryptoLoader.h>
#import <Masonry/Masonry.h>


@interface SamRoomVC()<AgoraRtcEngineDelegate>

- (IBAction)onbutton_joinroom_leave:(id)sender;

@property (strong, nonatomic) NSString *appid;
@property (assign, nonatomic) AgoraVideoProfile videoProfile;
@property (assign, nonatomic) NSString *encrypType;
@property (assign, nonatomic) NSString *encrypSecret;
@property (assign, nonatomic) NSString *roomName;

@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;
@property (strong, nonatomic) AgoraRtcCryptoLoader *agoraLoader;

@property (strong, nonatomic) AgoraRtcVideoCanvas *localcanvas;
@property (strong, nonatomic) UIView *localVideoView;



@end


@implementation SamRoomVC

static NSInteger streamID = 0;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.appid = @"665da0479681474191c7ef70058d2651";
    self.videoProfile = AgoraVideoProfileLandscape360P;
    self.encrypType = @"aes-128-xts";  // @"aes-256-xts"
    self.encrypSecret =@"samsecret";
    self.roomName =@"001";
    
    
    
    self.localVideoView = [[UIView alloc] init];
    self.localVideoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.localVideoView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.localVideoView];
    
    
    
    [self.localVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(50);
        make.bottom.equalTo(self.view.mas_bottom).offset(-50);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(150);
        
    }];
    
    
    
    
    //初始化AgoraKit
    self.agoraLoader = [[AgoraRtcCryptoLoader alloc] init];
    [self loadAgoraKit];
}




#pragma mark - Agora Media SDK
- (void)loadAgoraKit {
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:self.appid delegate:self];
    [self.agoraKit setChannelProfile:AgoraChannelProfileCommunication];
    [self.agoraKit enableVideo];
    [self.agoraKit setVideoProfile:self.videoProfile swapWidthAndHeight:NO];
    
    [self.agoraKit setEncryptionMode:self.encrypType];
    [self.agoraKit setEncryptionSecret:self.encrypSecret];
    
    [self.agoraKit createDataStream:&streamID reliable:YES ordered:YES];
    
    self.localcanvas = [[AgoraRtcVideoCanvas alloc] init];
    self.localcanvas.uid = 0;  //local video preview
    self.localcanvas.renderMode = AgoraVideoRenderModeFit;
    self.localcanvas.view = self.localVideoView;
    
    [self.agoraKit setupLocalVideo:self.localcanvas];
    [self.agoraKit startPreview];  //点亮自己的视频
    
    
    
}



- (IBAction)onbutton_joinroom_leave:(id)sender {
    
    NSLog(@"I click to join  room with uid:56");
    
    //
    //    [self.agoraKit leaveChannel:^(AgoraChannelStats * _Nonnull stat) {
    //        NSLog(@"I click to leave room with uid:0");
    //    }];
    
    //加入房间
    int code = [self.agoraKit joinChannelByToken:nil channelId:self.roomName info:nil uid:56 joinSuccess:nil];
    if (code == 0) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@", [NSString stringWithFormat:@"Join channel failed: %d", code]);
        });
    }
    
    
}





#pragma mark - <AgoraRtcEngineDelegate>

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    NSLog(@"somebody remote firstRemoteVideoDecodedOfUid come");
    
    //    VideoSession *userSession = [self videoSessionOfUid:uid];
    //    userSession.size = size;
    //    [self.agoraKit setupRemoteVideo:userSession.canvas];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed {
    NSLog(@"I joined room!");
    //    if (self.videoSessions.count) {
    //        VideoSession *selfSession = self.videoSessions.firstObject;
    //        selfSession.size = size;
    //        [self updateInterfaceWithSessions:self.videoSessions targetSize:self.containerView.frame.size animation:NO];
    //    }
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didJoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed{
    
    NSLog(@"somebody remote didJoinChannel: %lu",(unsigned long)uid);
    
    
}


- (void)rtcEngine:(AgoraRtcEngineKit * )engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed{
    NSLog(@"somebody remote didJoinedOfUid: %lu",(unsigned long)uid);
    
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    NSLog(@"somebody remote didOfflineOfUid: %lu",(unsigned long)uid);
    
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid {
}

-(void)rtcEngine:(AgoraRtcEngineKit *)engine receiveStreamMessageFromUid:(NSUInteger)uid streamId:(NSInteger)streamId data:(NSData *)data {
    //    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //    [self.msgTableView appendMsgToTableViewWithMsg:message msgType:MsgTypeChat];
}

- (void)rtcEngineConnectionDidInterrupted:(AgoraRtcEngineKit *)engine {
    //    [self.msgTableView appendMsgToTableViewWithMsg:@"Connection Did Interrupted" msgType:MsgTypeError];
}

- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *)engine {
    //    [self.msgTableView appendMsgToTableViewWithMsg:@"Connection Did Lost" msgType:MsgTypeError];
}

@end
