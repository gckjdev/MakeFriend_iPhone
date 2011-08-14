//
//  PrivateMessageTableViewCell.m
//  Dipan
//
//  Created by qqn_pipi on 11-6-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PrivateMessageTableViewCell.h"
#import "PrivateMessage.h"

@implementation PrivateMessageTableViewCell
@synthesize messageLabel;
@synthesize dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [messageLabel release];
    [dateLabel release];
    [super dealloc];
}

+ (NSString*)getCellIdentifier
{
    return @"PrivateMessageCell";
}

- (void)setCellStyle
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;		   
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;        
}

- (void)awakeFromNib{
    [self setCellStyle];
}

+ (PrivateMessageTableViewCell*)createCell
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PrivateMessgaeCell" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"<createPrivateMessageTableViewCell> but cannot find cell object");
        return nil;
    }
        
    return (PrivateMessageTableViewCell*)[topLevelObjects objectAtIndex:0];
}

+ (CGFloat)getCellHeight
{
    return 60;
}

- (void)setCellInfoWithMessage:(PrivateMessage*)message
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    self.dateLabel.text = [dateFormatter stringFromDate:message.createDate];
    [dateFormatter release];
    
    CGRect fra = self.messageLabel.frame;
    CGSize size = fra.size;
    size = CGSizeMake(size.width, 10000);
    size = [message.content sizeWithFont:self.messageLabel.font constrainedToSize:size];
    CGFloat d = fra.size.height - size.height;
    fra = CGRectMake(fra.origin.x, fra.origin.y, fra.size.width, size.height);
    self.messageLabel.frame = fra;
    self.messageLabel.text = message.content;
    fra = self.frame;
    fra = CGRectMake(fra.origin.x, fra.origin.y, fra.size.width, fra.size.height - d);
    self.frame = fra;
}


@end
