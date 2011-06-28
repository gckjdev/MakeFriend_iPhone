//
//  PostActionCell.h
//  Dipan
//
//  Created by qqn_pipi on 11-6-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PostActionCell : UITableViewCell {
    
}

+ (PostActionCell*)createCell;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeight;

@end
