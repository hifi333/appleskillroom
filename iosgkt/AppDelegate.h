
//
//  AppDelegate.h
//  testxcode
//
//  Created by sam.zhang on 2018/6/4.
//  Copyright © 2018年 sam.zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (strong, nonatomic)  WKWebView *createdWeview_room;
@property (strong, nonatomic)  NSString *loginUserId;
@property (strong, nonatomic)  NSString *loginSessionToken;
@property (strong, nonatomic)  NSString *loginRole;
@property (strong, nonatomic)  NSString *loginClassName;
@property (strong, nonatomic)  NSString *workmodel;

@end
