//
//  TwitterTableViewCell.h
//  USPTO
//
//  Created by Jared Crawford on 6/25/11.
//  Copyright 2011 Jared Crawford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextBubbleView.h"

@interface TwitterTableViewCell : UITableViewCell{
}

@property (nonatomic) BOOL isRightAligned;

-(void)configureWithTweet:(NSDictionary *)tweet;
-(NSString *)textOfTweet;
+(CGFloat)heightForCellWithText:(NSString *)text inViewWithWidth:(CGFloat)superviewWidth;

@end
