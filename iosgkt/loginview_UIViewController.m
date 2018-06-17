
//
//  loginview_UIViewController.m
//  testxcode
//
//  Created by sam.zhang on 2018/6/4.
//  Copyright © 2018年 sam.zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "loginview_UIViewController.h"
#import "devicelist_UIViewController.h"
#import "deviceSetting_UITabBarController.h"
#import <AFNetworking.h>
#import <Masonry/Masonry.h>
#import "AppDelegate.h"

@interface loginview_UIViewController ()

@end

@implementation loginview_UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    _label_username.backgroundColor = [UIColor orangeColor];
    _label_password.backgroundColor = [UIColor orangeColor];
    
    
    [_label_username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(100);
        make.left.equalTo(self.view.mas_left).offset(10);
        // make.centerY.equalTo(_label_username.mas_centerY);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(35);
        
    }];
    
    
    [_text_username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_label_username.mas_right).offset(1);
        make.top.equalTo(self->_label_username.mas_top);
        make.height.mas_equalTo(35);
        make.right.equalTo(self.view.mas_right).offset(-10);
    }];
    
    
    [_label_password mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_label_username.mas_bottom).offset(20);
        make.left.equalTo(self->_label_username.mas_left);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(35);
    }];
    
    [_text_password mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_text_username.mas_left);
        make.top.equalTo(self->_label_password.mas_top);
        make.height.mas_equalTo(35);
        make.right.equalTo(self->_text_username.mas_right);
    }];
    
    
    [_button_login mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self->_label_password.mas_left);
        make.top.equalTo(self->_label_password.mas_bottom).offset(30);
        make.height.mas_equalTo(45);
        make.right.equalTo(self->_text_password.mas_right);
        
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
                
                
                deviceSetting_UITabBarController *nextVc = deviceSetting_UITabBarController.getVCfromStoryboard;
                [self.navigationController pushViewController:nextVc  animated:(YES)];
                //    [self presentViewController:nextVc animated:(BOOL)YES completion:^{}];
                
            }
        }
    }];
    [dataTask resume];
    
    
    
}
- (IBAction)button_join:(id)sender {
}
@end

