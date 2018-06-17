

//
//  devicesettting_tab2.m
//  testxcode
//
//  Created by sam.zhang on 2018/6/5.
//  Copyright © 2018年 sam.zhang. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "devicesettting_tab2.h"
#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>


@interface devicesettting_tab2 ()
@property (weak, nonatomic) IBOutlet WKWebView *tab2webview;

@end

@implementation devicesettting_tab2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [_tab2webview mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        
    }];
    
    NSString *value = [NSString stringWithFormat:@"http://www.ifeng.com"];
    NSURL *url = [NSURL URLWithString:value];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_tab2webview loadRequest:request];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


+ (instancetype) getVCfromStoryboard{
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    devicesettting_tab2 *nextVc = [storyboard instantiateViewControllerWithIdentifier:@"devicesettting_tab2"];
    
    return nextVc;
}

@end

