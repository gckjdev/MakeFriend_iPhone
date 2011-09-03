//
//  MyInfoController.h
//  Dipan
//
//  Created by qqn_pipi on 11-4-30.
//  Copyright 2011 QQN-PIPI.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "HJManagedImageV.h"

@interface MyInfoController : PPTableViewController <UIActionSheetDelegate> {
    UILabel         *loginIdLabel;
    HJManagedImageV *avatarImageView;
    
    UIImage *avatar;
    NSString *nickName;
    NSString *genderText;
    NSString *mobile;
}

@property (nonatomic, retain) IBOutlet UILabel         *loginIdLabel;
@property (nonatomic, retain) IBOutlet HJManagedImageV *avatarImageView;

@property (nonatomic, retain) UIImage *avatar;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSString *genderText;
@property (nonatomic, retain) NSString *mobile;

- (IBAction)clickLogout:(id)sender;
- (IBAction)clickAvatar:(id)sender;

@end
