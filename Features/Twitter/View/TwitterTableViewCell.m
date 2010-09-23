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
@synthesize userIcon;
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
    switch (alignment){
        case TwitterTableViewCellAlignmentLeft:
            reuseIdentifier = @"TwitterTableViewCellLeft";
            textBackgroundColor = [[UIColor WVUGoldColor] retain];
            break;
        case TwitterTableViewCellAlignmentRight:
        default:
            reuseIdentifier = @"TwitterTableViewCellRight";
            textBackgroundColor = [[UIColor WVUBlueColor] retain];
            break;
    }
    
    self = (TwitterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!self) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:reuseIdentifier owner:self options:nil];
        self = [nib objectAtIndex:0];
        timestampLabel.font = [UIFont systemFontOfSize:SIZE_OF_TIMESTAMP];
        timestampLabel.adjustsFontSizeToFitWidth = YES;
        timestampLabel.backgroundColor = tableView.backgroundColor;
        timestampLabel.contentMode = UIViewContentModeTop;
        timestampLabel.textColor = [UIColor grayColor];
        NSString *imageName;
        switch (alignment){
            case TwitterTableViewCellAlignmentLeft:
                imageName = @"YellowBubble.png";
                textColor = [[UIColor WVUBlueColor] retain];
                break;
            case TwitterTableViewCellAlignmentRight:
            default:
                imageName = @"BlueBubble.png";
                textColor = [[UIColor WVUGoldColor] retain];
                break;
        }
        bubbleImage = [[[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:20 topCapHeight:20] retain];
		userIcon.clipsToBounds = YES;
		userIcon.layer.cornerRadius = 5;
		
        

    }
    
    //now we have a reused cell, we need to configure it appropriately
    self.bubbleAlignment = alignment;
	self.messageText = tweetText;
    
    timestampLabel.text = [timestamp stringDaysAgo];
	if ([timestampLabel.text isEqualToString:@"Today"]) {
		NSString *todaysTime = [NSString stringWithFormat:@"Today at %@", [NSDate stringForDisplayFromDate:timestamp]];
		timestampLabel.text = todaysTime;
	}
    
    
    return self;
}


- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];

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
	CGRect bubbleRect = CGRectMake(xOfBubble, Y_OF_BUBBLE, bubbleSize.width, bubbleSize.height);
	CGRect messageRect = CGRectMake(xOfMessage, Y_OF_BUBBLE + BUBBLE_TOP_OR_BOTTOM_MARGIN, textSize.width, textSize.height);
	
	[bubbleImage drawInRect:bubbleRect];
	[textColor set];
	[messageText drawInRect:messageRect withFont:[[self class] messageFont]];
	
    
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
	self.timestampLabel = nil;
	self.userIcon = nil;
	self.messageText = nil;
	[bubbleImage release];
	[textColor release];
	[textBackgroundColor release];
	
    [super dealloc];
}


@end
