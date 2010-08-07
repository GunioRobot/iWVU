//
//  TwitterTableViewCell.h
//  iWVU
//
//  Created by Jared Crawford on 8/6/10.
//  Copyright (c) 2010 Jared Crawford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>


typedef enum {
    TwitterTableViewCellAlignmentRight,
    TwitterTableViewCellAlignmentLeft
} TwitterTableViewCellAlignment;


@interface TwitterTableViewCell : UITableViewCell {
    
    IBOutlet UILabel *timestampLabel;
    IBOutlet UIView *bubbleArea;
    IBOutlet UIImageView *userIcon;
    UIImageView *bubbleImageView;
    TTStyledTextLabel *messageTextBox;
    TwitterTableViewCellAlignment bubbleAlignment;
    float cellHeight;
}

@property (nonatomic, retain) UILabel *timestampLabel;
@property (nonatomic, retain) UIImageView *bubbleImageView;
@property (nonatomic, retain) UIImageView *userIcon;
@property (nonatomic, retain) TTStyledTextLabel *messageTextBox;
@property (nonatomic) TwitterTableViewCellAlignment bubbleAlignment;
@property (nonatomic) float cellHeight;

-(id)initWithUsername:(NSString *)username messageText:(NSString *)messageText andAlignment:(TwitterTableViewCellAlignment)alignment;

@end
