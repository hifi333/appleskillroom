
//
//  devicelist_UIViewController.m
//  testxcode
//
//  Created by sam.zhang on 2018/6/4.
//  Copyright © 2018年 sam.zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "skillroom_uiviewController.h"
#import <Masonry/Masonry.h>
#import "AppDelegate.h"
#import "OnlineVideoSession.h"
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import <AgoraRtcCryptoLoader/AgoraRtcCryptoLoader.h>
#import "AppDelegate.h"


@interface skillroom_uiviewController ()<AgoraRtcEngineDelegate, WKScriptMessageHandler>

@property (weak, nonatomic) IBOutlet UIScrollView *samscrollview;


@property (strong, nonatomic) NSString *appid;
@property (assign, nonatomic) AgoraVideoProfile videoProfile;
@property (assign, nonatomic) NSString *encrypType;
@property (assign, nonatomic) NSString *encrypSecret;
@property (assign, nonatomic) NSString *roomName;

@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;
@property (strong, nonatomic) AgoraRtcCryptoLoader *agoraLoader;

@property (strong, nonatomic) AgoraRtcVideoCanvas *localcanvas;
@property (strong, nonatomic) UIView *localVideoView;
@property (strong, nonatomic) NSMutableArray<OnlineVideoSession *> *onlinevideoSessions;

@property BOOL  bejoin;

@end

@implementation skillroom_uiviewController

static NSInteger streamID = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // [self.navigationController setNavigationBarHidden:(YES) animated:(YES)];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _bejoin = NO;
    

    self.appid = @"665da0479681474191c7ef70058d2651";
    self.videoProfile = AgoraVideoProfileLandscape360P;
    self.encrypType = @"aes-128-xts";  // @"aes-256-xts"
    self.encrypSecret =@"samsecret";
    self.roomName =@"001";
    
    
    [appDelegate.createdWeview_room.configuration.userContentController addScriptMessageHandler:self name:@"joinVideo"]; //添加注入js方法, oc与js端对应实现

    
    [self.view addSubview:appDelegate.createdWeview_room];
    [appDelegate.createdWeview_room mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        
    }];
    
    [self loadWhiteboardJs];
    
    [self.view bringSubviewToFront:_samscrollview];

    
    
    [_samscrollview mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.view.mas_centerY);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.height.mas_equalTo(160);
        make.width.mas_equalTo(100);

    }];
    
    
    //设置本地的preview video winow
    self.localVideoView = [[UIView alloc] init];
    self.localVideoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.localVideoView.backgroundColor = [UIColor clearColor];
    
    
    //初始化AgoraKit
    self.onlinevideoSessions = [[NSMutableArray alloc] init];
    self.agoraLoader = [[AgoraRtcCryptoLoader alloc] init];
    [self loadAgoraKit];
    
    
    
    //布局scrollview 里面的video window
    
    //开始设置scrollview
//    _samscrollview.backgroundColor = [UIColor orangeColor];
    _samscrollview.userInteractionEnabled = YES;
    _samscrollview.scrollEnabled= YES;
    _samscrollview.showsHorizontalScrollIndicator =YES;
    
    
    [self updateLayoutVideoViewScroll];
    
    

    
}


-(void) loadWhiteboardJs{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSString * jsString  =[NSString stringWithFormat:@"appcallthis('%@','%@','%@','%@','%@')",appDelegate.loginUserId,appDelegate.loginSessionToken,appDelegate.loginRole,appDelegate.loginClassName,appDelegate.workmodel];
    
    NSLog(@"开始调用webview 的 js api:appcallthis ");
    NSLog(@"%@", jsString);
    
    [appDelegate.createdWeview_room evaluateJavaScript:jsString completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"value: %@ error: %@", response, error);
    }];
    
    
}


#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    //oc原生处理:
    
    NSLog(@"call back from js call.");
    NSLog(@"%@", message.name);
    
    if ([message.name isEqualToString:@"joinVideo"]) {
        NSDictionary * messageDict = (NSDictionary *)message.body;
        
        NSLog(@"js call xcode api: joinVideo");
        NSLog(@"%@", message.body);
        NSLog(@"%@", messageDict[@"eclassroom"]);
        NSLog(@"%@", messageDict[@"loginUserId"]);
   
        [self button_joinVideo];
    }
    
    if ([message.name isEqualToString:@"muteSpeaker"]) {
        NSDictionary * messageDict = (NSDictionary *)message.body;
        
        NSLog(@"js call xcode api: muteSpeaker");
        NSLog(@"%@", message.body);
        NSLog(@"%@", messageDict[@"loginUserId"]);
        
        [self button_joinVideo];
    }
    
    
    if ([message.name isEqualToString:@"mutecam"]) {
        NSDictionary * messageDict = (NSDictionary *)message.body;
        
        NSLog(@"js call xcode api: mutecam");
        NSLog(@"%@", message.body);
        NSLog(@"%@", messageDict[@"loginUserId"]);
        
        [self button_joinVideo];
    }
    
    
    if ([message.name isEqualToString:@"quiteclassroom"]) {
        NSDictionary * messageDict = (NSDictionary *)message.body;
        
        NSLog(@"js call xcode api: quiteclassroom");
        NSLog(@"%@", message.body);
        NSLog(@"%@", messageDict[@"loginUserId"]);
        
        [self button_joinVideo];
    }
    
    
    if ([message.name isEqualToString:@"hidevideowin"]) {
        NSDictionary * messageDict = (NSDictionary *)message.body;
        
        NSLog(@"js call xcode api: hidevideowin");
        NSLog(@"%@", message.body);
        NSLog(@"%@", messageDict[@"loginUserId"]);
        
        [self button_joinVideo];
    }
    
    
    
    
    
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
    
    
    //初始化，本地localpreivew 摄像头
//    OnlineVideoSession *localSession = [OnlineVideoSession createLocalSession];
//    [self.onlinevideoSessions addObject:localSession];
//     [self.agoraKit setupLocalVideo:localSession.rtcCanvas];
//
//    [self.agoraKit startPreview];  //点亮自己的视频
//
    
}


-(void) button_joinVideo {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    int myuid = appDelegate.loginUserId.intValue;
    if(_bejoin)
    {
        [self.agoraKit leaveChannel:^(AgoraChannelStats * _Nonnull stat) {
            NSLog(@"leave channel, 我的头像也去掉了. ");
        }];
              _bejoin = NO;
    }else
    {
        NSLog(@"I click to join  room with uid:%d" , myuid);
        
        //启动自己的视频
            OnlineVideoSession *localSession = [OnlineVideoSession createLocalSession];
            [self.onlinevideoSessions addObject:localSession];
            [self.agoraKit setupLocalVideo:localSession.rtcCanvas];
            [self.agoraKit startPreview];  //点亮自己的视频

        
        
        //加入房间
        int code = [self.agoraKit joinChannelByToken:nil channelId:self.roomName info:nil uid:myuid joinSuccess:nil];
        if (code == 0) {
            [UIApplication sharedApplication].idleTimerDisabled = YES;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@", [NSString stringWithFormat:@"Join channel failed: %d", code]);
            });
        }
        
        _bejoin=YES;
    }
    
    
}





-(void) updateLayoutVideoViewScroll{
    
  
    NSLog(@"update layout...");
    NSLog(@"%lu", (unsigned long)self.onlinevideoSessions.count);

    //动态设置这个scrollview 的高度， 系统提示错误。
//    [_samscrollview mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(60* self.onlinevideoSessions.count);
//    }];
    
    int k=0;
    for (OnlineVideoSession *session in self.onlinevideoSessions) {

        [_samscrollview addSubview: session.hostingUIView];

        [session.hostingUIView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.samscrollview.mas_top).offset(60*k );
            make.left.equalTo(self.samscrollview.mas_left);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(60);
        }];
        
        
        k++;

    }
    
    _samscrollview.contentSize = CGSizeMake(100, self.onlinevideoSessions.count*60);

    
//
//
//    UIImage *image1=[UIImage imageNamed:@"xiongmao12"];
//
//    UIImageView *samImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
//    samImageView.image = image1;
//    samImageView.contentMode = UIViewContentModeScaleAspectFit;
//
//
//    UIImageView *samImageView33 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
//    samImageView33.image = image1;
//    samImageView33.contentMode = UIViewContentModeScaleAspectFit;
//
//
//    [_samscrollview addSubview:samImageView];
//    [_samscrollview addSubview:samImageView33];
//
//    [samImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.samscrollview.mas_left);
//        make.top.equalTo(self.samscrollview.mas_top);
//        make.width.mas_equalTo(80);
//        make.height.mas_equalTo(80);
//    }];
//
//    [samImageView33 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.samscrollview.mas_left).offset(500);
//        make.top.equalTo(self.samscrollview.mas_top);
//        make.width.mas_equalTo(80);
//        make.height.mas_equalTo(80);
//
//    }];
//
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - <AgoraRtcEngineDelegate>

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    NSLog(@"somebody remote firstRemoteVideoDecodedOfUid come%lu",(unsigned long)uid);
    
    NSLog(@"videiosize: %f,%lf",size.width,size.height);
    
    BOOL isNewSession = YES;
    for (OnlineVideoSession *oneSession in self.onlinevideoSessions) {
        if(oneSession.remoteUid == uid)   isNewSession = NO;
    }
    if(isNewSession){
        OnlineVideoSession *newSession = [[OnlineVideoSession alloc] initWithUid:uid];
        [self.onlinevideoSessions addObject:newSession];
        [self.agoraKit setupRemoteVideo:newSession.rtcCanvas];
        [self updateLayoutVideoViewScroll];
        }
}


- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed {
    NSLog(@"I joined room!");
    [self updateLayoutVideoViewScroll];

    
    
    
    
    
    //    if (self.videoSessions.count) {
    //        VideoSession *selfSession = self.videoSessions.firstObject;
    //        selfSession.size = size;
    //        [self updateInterfaceWithSessions:self.videoSessions targetSize:self.containerView.frame.size animation:NO];
    //    }
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didLeaveChannelWithStats:(AgoraChannelStats * _Nonnull)stats{
    NSLog(@"I leaved room!");

    自己下线， 没有事件啊。。 有个事件， 操作这个sesionlist 也会出错呢，  然后重新布局也会出错。
    
    for (OnlineVideoSession *oneSession in self.onlinevideoSessions) {
        // if(oneSession.remoteUid !=0) {  //自己的preview video 一直留着。。。
        [oneSession.hostingUIView removeFromSuperview];
        [self.onlinevideoSessions removeObject:oneSession];
        //  }
    }
    [self updateLayoutVideoViewScroll];

    
    
}




- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didJoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed{
   
    
    
}


- (void)rtcEngine:(AgoraRtcEngineKit * )engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed{
    NSLog(@"somebody remote didJoinedOfUid: %lu",(unsigned long)uid);
    
    
    NSLog(@"somebody remote didJoinChannel: %lu",(unsigned long)uid);
    
    BOOL isNewSession = YES;
    for (OnlineVideoSession *oneSession in self.onlinevideoSessions) {
        if(oneSession.remoteUid == uid)   isNewSession = NO;
    }
    if(isNewSession){
        OnlineVideoSession *newSession = [[OnlineVideoSession alloc] initWithUid:uid];
        [self.onlinevideoSessions addObject:newSession];
        [self.agoraKit setupRemoteVideo:newSession.rtcCanvas];
        [self updateLayoutVideoViewScroll];
    }
    
    
    
    
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    NSLog(@"somebody remote didOfflineOfUid: %lu",(unsigned long)uid);
    
    
    for (OnlineVideoSession *oneSession in self.onlinevideoSessions) {
        if(oneSession.remoteUid == uid) {
            [oneSession.hostingUIView removeFromSuperview];
            [self.onlinevideoSessions removeObject:oneSession];
            [self updateLayoutVideoViewScroll];
        }
    }
    
    
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



+ (instancetype) getVCfromStoryboard{
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    skillroom_uiviewController *nextVc = [storyboard instantiateViewControllerWithIdentifier:@"deviceliststoryid"];
    
    return nextVc;
}



-(void)forceOrientationPortrait{
    
    //加上代理类里的方法，旋转屏幕可以达到强制竖屏的效果
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForcePortrait=YES;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
    
}

-(void)forceOrientationLandscape{
    //这种方法，只能旋转屏幕不能达到强制横屏的效果
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationLandscapeLeft;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    //加上代理类里的方法，旋转屏幕可以达到强制横屏的效果
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForceLandscape=YES;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
    
}


-(void)viewDidAppear:(BOOL)animated{
//    [self forceOrientationPortrait];  //设置竖屏
    [self forceOrientationLandscape]; //设置横屏
}


@end

