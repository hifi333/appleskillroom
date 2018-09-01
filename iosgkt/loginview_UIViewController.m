
//
//  loginview_UIViewController.m
//  testxcode
//
//  Created by sam.zhang on 2018/6/4.
//  Copyright © 2018年 sam.zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "loginview_UIViewController.h"
#import "skillroom_uiviewController.h"
#import "gkt_UITabBarController.h"
#import <AFNetworking.h>
#import <Masonry/Masonry.h>
#import "AppDelegate.h"

@interface loginview_UIViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *username_image;

@property (weak, nonatomic) IBOutlet UIImageView *password_image;
@property (weak, nonatomic) IBOutlet UIImageView *gkttuzi_image;

@end

@implementation loginview_UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [_gkttuzi_image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(30);
        make.left.equalTo(self.view.mas_left).offset(10);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(150);

    }];
    
    [_newuserresiter_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(50);
        make.right.equalTo(self.view.mas_right).offset(-10);
    }];
    
    
    [_welcomegkt_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_gkttuzi_image.mas_bottom).offset(30);
        make.left.equalTo(self.view.mas_left).offset(10);
        
    }];
    
    
    
    [_username_image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_welcomegkt_label.mas_top).offset(30);
        make.left.equalTo(self.view.mas_left).offset(10);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(35);
        
    }];
    
    
    [_text_username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_username_image.mas_right).offset(1);
        make.top.equalTo(self->_username_image.mas_top);
        make.height.mas_equalTo(35);
        make.right.equalTo(self.view.mas_right).offset(-10);
    }];
    

    [_password_image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_username_image.mas_bottom).offset(20);
        make.left.equalTo(self->_username_image.mas_left);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(35);
    }];

    [_text_password mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_text_username.mas_left);
        make.top.equalTo(self->_password_image.mas_top);
        make.height.mas_equalTo(35);
        make.right.equalTo(self->_text_username.mas_right);
    }];


    [_button_login mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.equalTo(self->_password_image.mas_left);
        make.top.equalTo(self->_password_image.mas_bottom).offset(30);
        make.height.mas_equalTo(45);
        make.right.equalTo(self->_text_password.mas_right);

    }];

    
    [_forgetpassword_label mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self->_button_login.mas_left);
        make.top.equalTo(self->_button_login.mas_bottom).offset(30);
    }];
    
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)dologin:(id)sender {
    //
    NSString *username = [_text_username text];
    NSString *pwd = [_text_password text];
    //    NSString *message = [NSString stringWithFormat:@"用户名：%@ 密码：%@", username, pwd ];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [alert show];
    
    
    //    devicelist_UIViewController *nextVc = devicelist_UIViewController.getVCfromStoryboard;
    //    nextVc.userId = @"https://www.youdao.com";
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    
    //申明返回的数据是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //    NSURL *URL = [NSURL URLWithString:@"http://localhost"];
    //    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSDictionary *parameters = @{@"userid": username, @"password": pwd};
    
    
    NSMutableURLRequest * samJsonPostReq = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"http://122.152.210.96/login" parameters:parameters error:nil];
    
    
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:samJsonPostReq completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
            
            //NSDictionary *jsonDic = (NSDictionary *)responseObject;
            NSString *loginSessionToken = responseObject[@"loginSessionToken"];
            
            NSLog(@"find the answer");
            NSLog(@"%@", loginSessionToken);
            
            if(loginSessionToken.length>0)  //login pass
            {
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.loginUserId = username;
                appDelegate.loginRole= @"0";
                appDelegate.loginSessionToken = loginSessionToken;
                
                
                gkt_UITabBarController *nextVc = gkt_UITabBarController.getVCfromStoryboard;
                [self.navigationController pushViewController:nextVc  animated:(YES)];
                //    [self presentViewController:nextVc animated:(BOOL)YES completion:^{}];
                
            }
        }
    }];
    [dataTask resume];
    
    
    
}
- (IBAction)button_join:(id)sender {
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
    [self forceOrientationPortrait];  //设置竖屏
//    [self forceOrientationLandscape]; //设置横屏
}

@end

