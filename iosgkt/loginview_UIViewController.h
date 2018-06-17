
//
//  loginview_UIViewController.h
//  testxcode
//
//  Created by sam.zhang on 2018/6/4.
//  Copyright © 2018年 sam.zhang. All rights reserved.
//

#ifndef loginview_UIViewController_h
#define loginview_UIViewController_h


#endif /* loginview_UIViewController_h */


#import <UIKit/UIKit.h>

@interface loginview_UIViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *text_username;
@property (weak, nonatomic) IBOutlet UITextField *text_password;

@property (weak, nonatomic) IBOutlet UILabel *label_username;
@property (weak, nonatomic) IBOutlet UILabel *label_password;

@property (weak, nonatomic) IBOutlet UIButton *button_login;

- (IBAction)dologin:(id)sender;


@end
