
#ifndef OnlineVideoSession_h
#define OnlineVideoSession_h


#endif /* OnlineVideoSession_h */


#import <UIKit/UIKit.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

@interface OnlineVideoSession : NSObject

@property (assign, nonatomic) NSUInteger remoteUid;

@property (strong, nonatomic) UIView *hostingUIView;
@property (strong, nonatomic) AgoraRtcVideoCanvas *rtcCanvas;

@property (assign, nonatomic) BOOL isVideoMuted;

- (instancetype)initWithUid:(NSUInteger)uid;

+ (instancetype)createLocalSession;

@end
