

//
//  deviceSetting_UITabBarController.m
//  testxcode
//
//  Created by sam.zhang on 2018/6/5.
//  Copyright © 2018年 sam.zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "gkt_UITabBarController.h"
#import "devicesettting_tab1.h"

#import "devicesettting_tab2.h"
#import "AppDelegate.h"


@interface gkt_UITabBarController ()
@property (weak, nonatomic) IBOutlet UITabBar *mytabbar;

@end

@implementation gkt_UITabBarController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tabBar.translucent = NO;
    self.tabBar.tintColor = [UIColor whiteColor];
    
    UIImage *background = [[UIImage imageNamed:@"背景图片"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    [self.tabBar setBackgroundImage:background];
    
    UIImage *selectedBackground = [[UIImage imageNamed:@"选中后的背景图片"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    [self.tabBar setSelectionIndicatorImage:selectedBackground];
    
    
    
    
    devicesettting_tab1 *tab1 = devicesettting_tab1.getVCfromStoryboard;
    devicesettting_tab2 *tab2 = devicesettting_tab2.getVCfromStoryboard;
    
    
    [self setTabBarItem:tab1.tabBarItem
                  Title:@"首页"
          withTitleSize:18.0
            andFoneName:@"Marion-Italic"
          selectedImage:@"orderError"
         withTitleColor:[UIColor blueColor]
        unselectedImage:@"orderSuccess"
         withTitleColor:[UIColor grayColor]];
    
    
    
    [self setTabBarItem:tab2.tabBarItem
                  Title:@"设置"
          withTitleSize:18.0
            andFoneName:@"Marion-Italic"
          selectedImage:@"orderError"
         withTitleColor:[UIColor blueColor]
        unselectedImage:@"orderSuccess"
         withTitleColor:[UIColor grayColor]];
    
    
    self.viewControllers = @[tab1 ,tab2];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    CGRect tabFrame = self.tabBar.frame;
    tabFrame.size.height = 48;
    tabFrame.origin.y = self.view.bounds.size.height - 48;
    self.tabBar.frame = tabFrame;
}

- (void)setTabBarItem:(UITabBarItem *)tabbarItem
                Title:(NSString *)title
        withTitleSize:(CGFloat)size
          andFoneName:(NSString *)foneName
        selectedImage:(NSString *)selectedImage
       withTitleColor:(UIColor *)selectColor
      unselectedImage:(NSString *)unselectedImage
       withTitleColor:(UIColor *)unselectColor{
    
    //设置图片
    tabbarItem = [tabbarItem initWithTitle:title image:[[UIImage imageNamed:unselectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    //未选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:unselectColor,NSFontAttributeName:[UIFont fontWithName:foneName size:size]} forState:UIControlStateNormal];
    
    //选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:selectColor,NSFontAttributeName:[UIFont fontWithName:foneName size:size]} forState:UIControlStateSelected];
}



+ (instancetype) getVCfromStoryboard{
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    gkt_UITabBarController *nextVc = [storyboard instantiateViewControllerWithIdentifier:@"deviceSetting_UITabBarController"];
    
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

