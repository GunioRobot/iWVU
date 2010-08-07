//
//  TwitterTableViewCell.m
//  iWVU
//
//  Created by Jared Crawford on 8/6/10.
//  Copyright (c) 2010 Jared Crawford. All rights reserved.
//

#import "TwitterTableViewCell.h"
#import "NSDate+Helper.h"

@implementation TwitterTableViewCell


-(id)initWithTableView:(UITableView *)tableView messageText:(NSString *)messageText timestamp:(NSDate *)timestamp andAlignment:(TwitterTableViewCellAlignment)alignment{
    
    NSString *reuseIdentifier;
    
    switch (alignment){
        case TwitterTableViewCellAlignmentLeft:
            reuseIdentifier = @"TwitterTableViewCellLeft";
            break;
        case TwitterTableViewCellAlignmentRight:
        default:
            reuseIdentifier = @"TwitterTableViewCellRight";
            break;
    }
    
    TwitterTableViewCell *cell = (TwitterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:reuseIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
        messageTextBox = [[TTStyledTextLabel alloc] initWithFrame:cell.bubbleImageView.frame];
        messageTextBox.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                           UIViewAutoresizingFlexibleWidth |
                                           UIViewAutoresizingFlexibleRightMargin |
                                           UIViewAutoresizingFlexibleTopMargin |
                                           UIViewAutoresizingFlexibleHeight |
                                           UIViewAutoresizingFlexibleBottomMargin);
        bubbleArea.backgroundColor = tableView.backgroundColor;
        messageTextBox.contentInset = UIEdgeInsetsMake(8, 10, 10, 13);
        messageTextBox.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        timestampLabel.font = [timestampLabel.font fontWithSize:8];
        timestampLabel.adjustsFontSizeToFitWidth = YES;
        timestampLabel.backgroundColor = tableView.backgroundColor;
        timestampLabel.contentMode = UIViewContentModeTop;
        timestampLabel.textColor = [UIColor grayColor];
        NSString *imageName;
        switch (alignment){
            case TwitterTableViewCellAlignmentLeft:
                imageName = @"BlueBubble.png";
                messageTextBox.textColor = [UIColor WVUGoldColor];
                break;
            case TwitterTableViewCellAlignmentRight:
            default:
                imageName = @"YellowBubble.png";
                messageTextBox.textColor = [UIColor WVUBlueColor];
                break;
        }
        bubbleImageView = [[UIImageView alloc] init];
        bubbleImageView.image = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
        

    }
    self = cell;
    
    //now we have a reused cell, we need to configure it appropriately
    messageTextBox.text = [TTStyledText textWithURLs:messageText lineBreaks:YES];
    
    timestampLabel.text = [timestamp stringDaysAgo];
	if ([timestampLabel.text isEqualToString:@"Today"]) {
		NSString *todaysTime = [NSString stringWithFormat:@"Today at %@", [NSDate stringForDisplayFromDate:timestamp]];
		timestampLabel.text = todaysTime;
	}
    
    userIcon.image = [UIImage imageNamed:@"FlyingWVSmall.png"];
    
    return self;
}


- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    //this is the redrawing code to ensure that text bubbles propperly handle autoresize for things like rotation
    float maximumWidthForText = bubbleArea.frame.size.width - self.messageTextBox.contentInset.left - self.messageTextBox.contentInset.right;
    CGSize textSize = [self.messageTextBox.text sizeWithFont:[UIFont systemFontOfSize:[UIFont labelFontSize]] constrainedToSize:CGSizeMake(maximumWidthForText,1000)];
    CGSize labelSize = CGSizeMake(textSize.width + self.messageTextBox.contentInset.left + self.messageTextBox.contentInset.right,
                                  textSize.height + self.messageTextBox.contentInset.top + self.messageTextBox.contentInset.bottom);
    self.messageTextBox.frame = CGRectMake(self.messageTextBox.frame.origin.x, self.messageTextBox.frame.origin.x, labelSize.height, labelSize.width);
    self.bubbleImageView.frame = self.messageTextBox.frame;
    self.cellHeight = labelSize.height + self.timestampLabel.frame.size.height + 5;
}

- (void)dealloc {
    [super dealloc];
}


@end
