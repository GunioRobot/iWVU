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

#define BUBBLE_WIDTH_ON_NON_CALLOUT_SIDE 5
#define BUBBLE_WIDTH_ON_CALLOUT_SIDE 10
#define BUBBLE_TOP_OR_BOTTOM_MARGIN 5
#define SIZE_OF_TIMESTAMP 11
#define IMAGE_TO_BUBBLE_BUFFER 5
#define Y_OF_BUBBLE 20
#define MIN_HEIGHT_OF_CELL 75

-(id)initWithTableView:(TwitterTableView *)tableView messageText:(NSString *)tweetText timestamp:(NSDate *)timestamp andAlignment:(TwitterTableViewCellAlignment)alignment{

    parentTableView = tableView;
    
    NSString *reuseIdentifier;
    UIColor *textBackgroundColor;
    switch (alignment){
        case TwitterTableViewCellAlignmentLeft:
            reuseIdentifier = @"TwitterTableViewCellLeft";
            textBackgroundColor = [UIColor WVUGoldColor];
            break;
        case TwitterTableViewCellAlignmentRight:
        default:
            reuseIdentifier = @"TwitterTableViewCellRight";
            textBackgroundColor = [UIColor WVUBlueColor];
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
        messageTextBox.backgroundColor = textBackgroundColor;
		messageTextBox.font = [TwitterTableViewCell messageFont];
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
		bubbleImageView.backgroundColor = tableView.backgroundColor;
		userIcon.clipsToBounds = YES;
		userIcon.layer.cornerRadius = 5;
		
        [self.contentView addSubview:bubbleImageView];
        [self.contentView addSubview:messageTextBox];

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
		float maximumWidthForText = [TwitterTableViewCell maximumTextWidthForWindowOfWidth:rect.size.width];
		CGSize textSize = [TwitterTableViewCell textSizeWithMessage:messageText andMaximumWidth:maximumWidthForText];
		CGSize bubbleSize = [TwitterTableViewCell bubbleSizeWithTextSize:textSize];
		
		float xOfBubble;
		float xOfMessage;
		if (bubbleAlignment == TwitterTableViewCellAlignmentLeft) {
			xOfBubble = userIcon.frame.origin.x + userIcon.frame.size.width + IMAGE_TO_BUBBLE_BUFFER;
			xOfMessage = xOfBubble + BUBBLE_WIDTH_ON_CALLOUT_SIDE;
		}
		else{
			xOfBubble = userIcon.frame.origin.x - bubbleSize.width - IMAGE_TO_BUBBLE_BUFFER;
			xOfMessage = xOfBubble + BUBBLE_WIDTH_ON_NON_CALLOUT_SIDE;
		}
		self.bubbleImageView.frame = CGRectMake(xOfBubble, Y_OF_BUBBLE, bubbleSize.width, bubbleSize.height);
		self.messageTextBox.frame = CGRectMake(xOfMessage, bubbleImageView.frame.origin.y + BUBBLE_TOP_OR_BOTTOM_MARGIN, textSize.width, textSize.height);
        [messageTextBox layoutIfNeeded];
		previousSize = rect.size;
        [parentTableView reloadTableViewAnimated];
	}
    
}

+(float)maximumTextWidthForWindowOfWidth:(float)width{
    return ((width * (276.0 / 376.0)) - BUBBLE_WIDTH_ON_CALLOUT_SIDE - BUBBLE_WIDTH_ON_NON_CALLOUT_SIDE);
}

+(CGSize)textSizeWithMessage:(NSString *)text andMaximumWidth:(float)maximumWidthForText{
    return [text sizeWithFont:[TwitterTableViewCell messageFont] constrainedToSize:CGSizeMake(maximumWidthForText,1000)];
}

+(CGSize)bubbleSizeWithTextSize:(CGSize)textSize{
    return CGSizeMake(textSize.width + BUBBLE_WIDTH_ON_CALLOUT_SIDE + BUBBLE_WIDTH_ON_NON_CALLOUT_SIDE,
                      textSize.height + BUBBLE_TOP_OR_BOTTOM_MARGIN + BUBBLE_TOP_OR_BOTTOM_MARGIN);
}

+(float)cellHeightWithBubbleSize:(CGSize)bubbleSize{
    float bubbleHeight = (bubbleSize.height + SIZE_OF_TIMESTAMP + 15);
	if (bubbleHeight < MIN_HEIGHT_OF_CELL) {
		bubbleHeight = MIN_HEIGHT_OF_CELL;
	}
	return bubbleHeight;
}

+(UIFont *)messageFont{
	return [UIFont fontWithName:@"Helvetica" size:14];
	//return [UIFont systemFontOfSize:[UIFont labelFontSize]];
}

- (void)dealloc {
    [super dealloc];
}


@end
