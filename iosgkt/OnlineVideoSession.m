//
//  OnlineVideoSession.m
//  OpenVideoCall
//
//  Created by eviewlake on 2018/6/15.
//  Copyright © 2018年 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OnlineVideoSession.h"

@implementation OnlineVideoSession
- (instancetype)initWithUid:(NSUInteger)remoteUid {
    if (self = [super init]) {
        self.remoteUid = remoteUid;
        
        self.hostingUIView = [[UIView alloc] init];
        self.hostingUIView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.rtcCanvas = [[AgoraRtcVideoCanvas alloc] init];
        self.rtcCanvas.uid = remoteUid;
        self.rtcCanvas.view = self.hostingUIView;
        self.rtcCanvas.renderMode = AgoraVideoRenderModeFit;
    }
    return self;
}

- (void)setIsVideoMuted:(BOOL)isVideoMuted {
   
}



+ (instancetype)createLocalSession {
    return [[OnlineVideoSession alloc] initWithUid:0];
}
@end
