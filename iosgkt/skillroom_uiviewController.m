
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
#import "gkt_UITabBarController.h"

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
@property BOOL  beSpeakerMute;
@property BOOL  beCamMute;

@end

@implementation skillroom_uiviewController

static NSInteger streamID = 0;


-(void) viewWillAppear:(BOOL)animated{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSLog(@"%@ from viewWillAppear ", _samStoryVCSingleTonInstanceTest);
    NSLog(@"%@ from viewWillAppear： load new classroom: ", appDelegate.loginClassName);

    
    [self loadWhiteboardJs];  //webview 布局OK了 ，开始load DOM for 新的classroom appDelegate.loginClassName
    

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // [self.navigationController setNavigationBarHidden:(YES) animated:(YES)];

    
    NSLog(@"%@", _samStoryVCSingleTonInstanceTest);
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _bejoin = NO;
    _beSpeakerMute =NO;
    _beCamMute =NO;

    self.appid = @"665da0479681474191c7ef70058d2651";
    self.videoProfile = AgoraVideoProfileLandscape360P;
    self.encrypType = @"aes-128-xts";  // @"aes-256-xts"
    self.encrypSecret =@"samsecret";
    self.roomName = appDelegate.loginClassName;
    

//    
//    [appDelegate.createdWeview_room.configuration.userContentController  removeScriptMessageHandlerForName:@"joinVideo"];
//    [appDelegate.createdWeview_room.configuration.userContentController  removeScriptMessageHandlerForName:@"muteSpeaker"];
//    [appDelegate.createdWeview_room.configuration.userContentController  removeScriptMessageHandlerForName:@"mutecam"];
//    [appDelegate.createdWeview_room.configuration.userContentController  removeScriptMessageHandlerForName:@"quiteclassroom"];
//    [appDelegate.createdWeview_room.configuration.userContentController  removeScriptMessageHandlerForName:@"hidevideowin"];
//
//    [appDelegate.createdWeview_room.configuration.userContentController addScriptMessageHandler:self name:@"joinVideo"]; //添加注入js方法, oc与js端对应实现
//    [appDelegate.createdWeview_room.configuration.userContentController addScriptMessageHandler:self name:@"muteSpeaker"]; //添加注入js方法, oc与js端对应实现
//    [appDelegate.createdWeview_room.configuration.userContentController addScriptMessageHandler:self name:@"mutecam"]; //添加注入js方法, oc与js端对应实现
//    [appDelegate.createdWeview_room.configuration.userContentController addScriptMessageHandler:self name:@"quiteclassroom"]; //添加注入js方法, oc与js端对应实现
//    [appDelegate.createdWeview_room.configuration.userContentController addScriptMessageHandler:self name:@"hidevideowin"]; //添加注入js方法, oc与js端对应实现

    [appDelegate.createdWeview_room removeFromSuperview];

    [self.view addSubview:appDelegate.createdWeview_room];
    [appDelegate.createdWeview_room mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        
    }];
    
    [self loadWhiteboardJs];  //webview 布局OK了 ，开始load DOM

    
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
        NSLog(@"执行webView render cavas,js 出错:");
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
        
        [self button_muteSpeaker];
    }
    
    
    if ([message.name isEqualToString:@"mutecam"]) {
        NSDictionary * messageDict = (NSDictionary *)message.body;
        
        NSLog(@"js call xcode api: mutecam");
        NSLog(@"%@", message.body);
        NSLog(@"%@", messageDict[@"loginUserId"]);
        
        [self button_mutecam];
    }
    
    
    if ([message.name isEqualToString:@"quiteclassroom"]) {
        NSDictionary * messageDict = (NSDictionary *)message.body;
        
        NSLog(@"js call xcode api: quiteclassroom");
        NSLog(@"%@", message.body);
        NSLog(@"%@", messageDict[@"loginUserId"]);
        
        [self button_quiteclassroom];
    }
    
    
    if ([message.name isEqualToString:@"hidevideowin"]) {
        NSDictionary * messageDict = (NSDictionary *)message.body;
        
        NSLog(@"js call xcode api: hidevideowin");
        NSLog(@"%@", message.body);
        NSLog(@"%@", messageDict[@"loginUserId"]);
        
        [self button_hidevideowin];
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
-(void) button_muteSpeaker {
    
    [self.agoraKit muteLocalAudioStream:!_beSpeakerMute];
    
    _beSpeakerMute =!_beSpeakerMute;

}

-(void) button_mutecam {

    [self.agoraKit muteLocalVideoStream:!_beCamMute];
    _beCamMute = !_beCamMute;

}



-(void) button_quiteclassroom {
    
    NSLog(@"%d", self.navigationController.viewControllers.count);

    
   for (UIViewController *controller in self.navigationController.viewControllers) {
       
       NSLog(@"%@", controller.class);
        if ([controller isKindOfClass:[gkt_UITabBarController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
}
}

-(void) button_hidevideowin {

    [_samscrollview setHidden:(!_samscrollview.isHidden)];
    
}







-(void) button_joinVideo {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    int myuid = appDelegate.loginUserId.intValue;
    if(_bejoin)
    {
        [self.agoraKit leaveChannel:^(AgoraChannelStats * _Nonnull stat) {
            NSLog(@"leave channel, 我的头像也去掉了. ");

            
            for (OnlineVideoSession *oneSession in self.onlinevideoSessions) {
                [oneSession.hostingUIView removeFromSuperview]; //当前所有视频窗口都要移除父亲依赖
            }
            [self.onlinevideoSessions removeAllObjects];  //清除当前所有窗口视频对象

            [self updateLayoutVideoViewScroll];  //清楚视频scrollview的内容。。  就是退出视频来， 自己的视频， 别人的视频， 都不看了。

            
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

            [self updateLayoutVideoViewScroll];

        
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




- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didJoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed{
    NSLog(@"local didJoinChannel: %lu",(unsigned long)uid);
    
    //不知为啥， 本地的视频操作没有触发这里啊。
    
}



- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed {
    NSLog(@"local, I joined room and videoframing:firstLocalVideoFrameWithSize");
    
    //不知为啥， 本地的视频操作没有触发这里啊。

    
  //  [self updateLayoutVideoViewScroll];

    //    if (self.videoSessions.count) {
    //        VideoSession *selfSession = self.videoSessions.firstObject;
    //        selfSession.size = size;
    //        [self updateInterfaceWithSessions:self.videoSessions targetSize:self.containerView.frame.size animation:NO];
    //    }
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didLeaveChannelWithStats:(AgoraChannelStats * _Nonnull)stats{
    NSLog(@"local didLeaveChannelWithStats");

    //自己下线， 没有事件啊。。 有个事件没有发出来，
    //不知为啥， 本地的视频操作没有触发这里啊。

}




- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    NSLog(@"remote firstRemoteVideoDecodedOfUid firstframing come%lu",(unsigned long)uid);
    
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

- (void)rtcEngine:(AgoraRtcEngineKit * )engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed{
    NSLog(@"remote didJoinedOfUid: %lu",(unsigned long)uid);
    
    
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
    NSLog(@"remote didOfflineOfUid: %lu",(unsigned long)uid);
    
    
    for (OnlineVideoSession *oneSession in self.onlinevideoSessions) {
        if(oneSession.remoteUid == uid) {
            [oneSession.hostingUIView removeFromSuperview];
            [self.onlinevideoSessions removeObject:oneSession];
            [self updateLayoutVideoViewScroll];
        }
    }
    
    
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

