//
//  TwitterTableViewCell.m
//  iWVU
//
//  Created by Jared Crawford on 8/6/10.
//  Copyright (c) 2010 Jared Crawford. All rights reserved.
//

#import "TwitterTableViewCell.h"
#import "NSDate+Helper.h"
#import "TTStyledTextLabel+URL.h"

@implementation TwitterTableViewCell

@synthesize timestampLabel;
@synthesize bubbleImageView;
@synthesize userIcon;
@synthesize messageTextBox;
@synthesize bubbleAlignment;
@synthesize messageText;

#define BUBBLE_TEXT_INSET 10
#define SIZE_OF_TIMESTAMP 11

-(id)initWithTableView:(TwitterTableView *)tableView messageText:(NSString *)tweetText timestamp:(NSDate *)timestamp andAlignment:(TwitterTableViewCellAlignment)alignment{

    parentTableView = tableView;
    
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
    
    self = (TwitterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!self) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:reuseIdentifier owner:self options:nil];
        self = [nib objectAtIndex:0];
        messageTextBox = [[TTStyledTextLabel alloc] initWithFrame:self.bubbleImageView.frame];
        messageTextBox.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                           UIViewAutoresizingFlexibleWidth |
                                           UIViewAutoresizingFlexibleRightMargin |
                                           UIViewAutoresizingFlexibleTopMargin |
                                           UIViewAutoresizingFlexibleHeight |
                                           UIViewAutoresizingFlexibleBottomMargin);
        bubbleArea.backgroundColor = tableView.backgroundColor;
        messageTextBox.backgroundColor = [UIColor clearColor];
        messageTextBox.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        timestampLabel.font = [UIFont systemFontOfSize:SIZE_OF_TIMESTAMP];
        timestampLabel.adjustsFontSizeToFitWidth = YES;
        timestampLabel.backgroundColor = tableView.backgroundColor;
        timestampLabel.contentMode = UIViewContentModeTop;
        timestampLabel.textColor = [UIColor grayColor];
        NSString *imageName;
        switch (alignment){
            case TwitterTableViewCellAlignmentLeft:
                imageName = @"YellowBubble.png";
                messageTextBox.textColor = [UIColor WVUBlueColor];
                break;
            case TwitterTableViewCellAlignmentRight:
            default:
                imageName = @"BlueBubble.png";
                messageTextBox.textColor = [UIColor WVUGoldColor];
                break;
        }
        bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        bubbleImageView.image = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
		
		userIcon.clipsToBounds = YES;
		userIcon.layer.cornerRadius = 5;
		
        [bubbleArea addSubview:bubbleImageView];
        [bubbleArea addSubview:messageTextBox];

    }
    
    //now we have a reused cell, we need to configure it appropriately
    self.bubbleAlignment = alignment;
	self.messageText = tweetText;
    messageTextBox.text = [TTStyledText textWithURLs:tweetText lineBreaks:YES];
    
    timestampLabel.text = [timestamp stringDaysAgo];
	if ([timestampLabel.text isEqualToString:@"Today"]) {
		NSString *todaysTime = [NSString stringWithFormat:@"Today at %@", [NSDate stringForDisplayFromDate:timestamp]];
		timestampLabel.text = todaysTime;
	}
    
    
    return self;
}


- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];

	if ((rect.size.width != previousSize.width) || (rect.size.height != previousSize.height)) {
        //this is the redrawing code to ensure that text bubbles propperly handle autoresize for things like rotation
		float maximumWidthForText = bubbleArea.frame.size.width - BUBBLE_TEXT_INSET - BUBBLE_TEXT_INSET;
        maximumWidthForText = [TwitterTableViewCell maximumTextWidthForWindowOfWidth:rect.size.width];
		CGSize textSize = [TwitterTableViewCell textSizeWithMessage:messageText andMaximumWidth:maximumWidthForText];
		CGSize bubbleSize = [TwitterTableViewCell bubbleSizeWithTextSize:textSize];
		
		if (bubbleAlignment == TwitterTableViewCellAlignmentLeft) {
			self.messageTextBox.frame = CGRectMake(BUBBLE_TEXT_INSET, BUBBLE_TEXT_INSET, textSize.width, textSize.height);
			self.bubbleImageView.frame = CGRectMake(0, 0, bubbleSize.width, bubbleSize.height);
		}
		else{
			float xOfBubble = bubbleArea.frame.size.width - bubbleSize.width;
			self.messageTextBox.frame = CGRectMake(xOfBubble + BUBBLE_TEXT_INSET, BUBBLE_TEXT_INSET, textSize.width, textSize.height);
			self.bubbleImageView.frame = CGRectMake(xOfBubble, 0, bubbleSize.width, bubbleSize.height);
		}
        //float cellHeight =  bubbleSize.height + self.timestampLabel.frame.size.height + 5;
        [messageTextBox layoutIfNeeded];
		previousSize = rect.size;
        [parentTableView reloadTableViewAnimated];
	}
    
}

+(float)maximumTextWidthForWindowOfWidth:(float)width{
    return ((width * (276.0 / 376.0)) - BUBBLE_TEXT_INSET - BUBBLE_TEXT_INSET);
}

+(CGSize)textSizeWithMessage:(NSString *)text andMaximumWidth:(float)maximumWidthForText{
    return [text sizeWithFont:[UIFont systemFontOfSize:[UIFont labelFontSize]] constrainedToSize:CGSizeMake(maximumWidthForText,1000)];
}

+(CGSize)bubbleSizeWithTextSize:(CGSize)textSize{
    return CGSizeMake(textSize.width + BUBBLE_TEXT_INSET + BUBBLE_TEXT_INSET,
                      textSize.height + BUBBLE_TEXT_INSET + BUBBLE_TEXT_INSET);
}

+(float)cellHeightWithBubbleSize:(CGSize)bubbleSize{
    return (bubbleSize.height + SIZE_OF_TIMESTAMP + 15);
}


- (void)dealloc {
    [super dealloc];
}


@end
