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
    
    CGSize size = CGSizeMake(250, 10000);
    size = [message.content sizeWithFont:self.messageLabel.font constrainedToSize:size];
    CGRect fra = self.messageLabel.frame;
    CGFloat d = fra.size.height - size.height;
    if (0 == [message.type intValue]) {
        fra = CGRectMake(10, 10, size.width, size.height);
    } else if (1 == [message.type intValue]) {
        fra = CGRectMake(310 - size.width, 10, size.width, size.height);
    }
    self.messageLabel.frame = fra;
    self.messageLabel.text = message.content;
    fra = self.dateLabel.frame;
    fra = CGRectMake(fra.origin.x, fra.origin.y - d, fra.size.width, fra.size.height);
    self.dateLabel.frame = fra;
    fra = self.frame;
    fra = CGRectMake(fra.origin.x, fra.origin.y, fra.size.width, fra.size.height - d);
    self.frame = fra;
    
    if (0 == [message.type intValue]) {
        self.dateLabel.textAlignment = UITextAlignmentLeft;
        //self.dateLabel.backgroundColor = [UIColor lightGrayColor];
        //self.messageLabel.backgroundColor = [UIColor lightGrayColor];
    } else if (1 == [message.type intValue]) {
        self.dateLabel.textAlignment = UITextAlignmentRight;
        //self.dateLabel.backgroundColor = [UIColor greenColor];
        //self.messageLabel.backgroundColor = [UIColor greenColor];
    }
}


@end
