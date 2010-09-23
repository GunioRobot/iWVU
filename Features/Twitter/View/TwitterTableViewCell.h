//
//  TwitterTableViewCell.h
//  iWVU
//
//  Created by Jared Crawford on 8/6/10.
//  Copyright (c) 2010 Jared Crawford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "TwitterTableView.h"


typedef enum {
    TwitterTableViewCellAlignmentRight,
    TwitterTableViewCellAlignmentLeft
} TwitterTableViewCellAlignment;


@interface TwitterTableViewCell : UITableViewCell {
    
    IBOutlet UILabel *timestampLabel;
    IBOutlet UIImageView *userIcon;
    UIImage *bubbleImage;
    TwitterTableViewCellAlignment bubbleAlignment;
    NSString *messageText;
    TwitterTableView *parentTableView;
	UIColor *textBackgroundColor;
	UIColor *textColor;
}

@property (nonatomic, retain) UILabel *timestampLabel;
@property (nonatomic, retain) UIImageView *userIcon;
@property (nonatomic) TwitterTableViewCellAlignment bubbleAlignment;
@property (nonatomic, retain) NSString *messageText;

-(id)initWithTableView:(TwitterTableView *)tableView messageText:(NSString *)tweetText timestamp:(NSDate *)timestamp andAlignment:(TwitterTableViewCellAlignment)alignment;

+(float)maximumTextWidthForWindowOfWidth:(float)width;
+(CGSize)textSizeWithMessage:(NSString *)text andMaximumWidth:(float)maxWith;
+(CGSize)bubbleSizeWithTextSize:(CGSize)textSize;
+(float)cellHeightWithBubbleSize:(CGSize)bubbleSize;
+(UIFont *)messageFont;

@end
