//
//  PublicTimelinePostController.h
//  Dipan
//
//  Created by qqn_pipi on 11-5-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "LocalDataService.h"
#import "PostTableViewCell.h"
#import "PostActionCell.h"
#import "PostService.h"

@class CreatePrivateMessageController;

@interface PublicTimelinePostController : PPTableViewController <LocalDataServiceDelegate,PostTableViewCellDelegate, PostServiceDelegate> {
    UIViewController                *superController;    
    CreatePrivateMessageController  *privateMssageController;
    NSIndexPath                     *selectedIndexPath;
}

@property (nonatomic, retain) UIViewController                  *superController;
@property (nonatomic, retain) CreatePrivateMessageController    *privateMssageController;
@property (nonatomic, retain) NSIndexPath                       *selectedIndexPath;

@end
