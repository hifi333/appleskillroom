

//
//  devicesettting_tab1.m
//  testxcode
//
//  Created by sam.zhang on 2018/6/5.
//  Copyright © 2018年 sam.zhang. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "devicesettting_tab1.h"
#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>
#import "devicelist_UIViewController.h"
#import "AppDelegate.h"

@interface devicesettting_tab1 () <WKNavigationDelegate,UIScrollViewDelegate,WKScriptMessageHandler>

@property (strong, nonatomic)  WKWebView *createdh5Weview;

@property (strong, nonatomic)  WKWebView *createdWeview_room;

@property  BOOL Index_app_loadOK;



@end

@implementation devicesettting_tab1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _Index_app_loadOK = NO;
    
   
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width ,user-scalable=no,initial-scale=1.0, minimum-scale=1.0,maximum-scale=1.0');  document.getElementsByTagName('head')[0].appendChild(meta);";
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    
    wkWebConfig.preferences = [[WKPreferences alloc] init];
    wkWebConfig.preferences.minimumFontSize = 12;
    wkWebConfig.preferences.javaScriptEnabled = YES;
    wkWebConfig.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    
    
    
    _createdh5Weview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:wkWebConfig];
    [wkWebConfig.userContentController addScriptMessageHandler:self name:@"joinRoom"];//添加注入js方法, oc与js端对应实现

    
    [self.view addSubview: _createdh5Weview];
    
    
    
    [_createdh5Weview mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        
    }];
    
    
    
    _createdh5Weview.navigationDelegate = self;
    
    NSString *value = [NSString stringWithFormat:@"http://122.152.210.96/lessionh5.html"];
    NSURL *url = [NSURL URLWithString:value];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_createdh5Weview loadRequest:request];
    NSLog(@"request to load lessionh5.html...");
    
    _createdh5Weview.scrollView.delegate = self;
    
    
    
    //load 下一个页面。。 准备下一个webview
    _createdWeview_room = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:wkWebConfig];
    NSString *roomvalue = [NSString stringWithFormat:@"http://122.152.210.96/index_app.html"];
    NSURL *roomurl = [NSURL URLWithString:roomvalue];
    NSURLRequest *roomrequest = [NSURLRequest requestWithURL:roomurl];
    [_createdWeview_room loadRequest:roomrequest];
    
    //_createdWeview_room.scrollView.delegate = self;
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.createdWeview_room = _createdWeview_room;
    
    appDelegate.createdWeview_room.navigationDelegate = self;
}


#pragma mark - WKNavigationDelegate


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    // NSString *jsString = @"hi('good good study')";
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *currentURL = webView.URL.absoluteString;
    NSLog(@"%@", currentURL);
    
    NSRange range = [currentURL rangeOfString:@"lessionh5.html"];
    if ( range.length > 0 ) {  //H5js 加载完成了， 马上执行js API
        NSString  *jsParameter1 = appDelegate.loginSessionToken;
        
        NSString * jsString  =[NSString stringWithFormat:@"tobeCalledfromLoginActivity('%@')",jsParameter1];
        
        [webView evaluateJavaScript:jsString completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            NSLog(@"value: %@ error: %@", response, error);
        }];
        
        NSLog(@"invoked lessionH5's js  api , to let js to load lessontable...");
    }
    
    if ( [currentURL rangeOfString:@"index_app.html"].length > 0 ) { //index_app 加载完成了， 马上执行js API, 显示roomwhiteobard
        
        
        _Index_app_loadOK = YES;
        
        NSLog(@"index_app js 加载完成。");
    }
    
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    //oc原生处理:
    
    NSLog(@"call back from js call.");
    NSLog(@"%@", message.name);
    
    if ([message.name isEqualToString:@"joinRoom"]) {
        NSDictionary * messageDict = (NSDictionary *)message.body;
        
        NSLog(@"%@", message.body);
        NSLog(@"%@", messageDict[@"eclassroom"]);
        NSLog(@"%@", messageDict[@"workmodel"]);
        //                if ([messageDict[@"userid"] isEqualToString:@"a1390"]) {
        //                    NSLog(@"登录ok");
        //                }
        //用户在lessontable 上选择Action
        if(_Index_app_loadOK) //js 加载完成后， 才能调用js API
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.loginClassName = messageDict[@"eclassroom"];
            appDelegate.workmodel = messageDict[@"workmodel"];
            
            devicelist_UIViewController *nextVc = devicelist_UIViewController.getVCfromStoryboard;
            [self.navigationController pushViewController:nextVc  animated:(YES)];
        }
        
    }
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return nil;
}

+ (instancetype) getVCfromStoryboard{
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    devicesettting_tab1 *nextVc = [storyboard instantiateViewControllerWithIdentifier:@"devicesettting_tab1"];
    
    return nextVc;
}



@end

