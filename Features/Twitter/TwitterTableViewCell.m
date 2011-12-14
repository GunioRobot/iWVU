//
//  TwitterTableViewCell.m
//  USPTO
//
//  Created by Jared Crawford on 6/25/11.
//  Copyright 2011 Jared Crawford. All rights reserved.
//

#import "TwitterTableViewCell.h"
#import "NSDate+Helper.h"
#import <QuartzCore/QuartzCore.h>
#import "JMImageCache.h"


#define TWITTER_TABLE_PADDING 5.0
#define TWITTER_TABLE_IMAGE_SIZE 50.0
#define TWITTER_TABLE_BUBBLE_TO_TEXT_SPACING 2.0
#define TWITTER_TABLE_TIMESTAMP_HEIGHT 15.0


@interface TwitterTableViewCell()<JMImageCacheDelegate>

@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) UIImageView *userIcon;
@property (nonatomic, strong) TextBubbleView *textView;

@end

@implementation TwitterTableViewCell

@synthesize isRightAligned;
@synthesize timestampLabel;
@synthesize userIcon;
@synthesize textView;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.userIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.textView = [[TextBubbleView alloc] initWithFrame:CGRectZero];
        [self addSubview:timestampLabel];
        [self addSubview:userIcon];
        [self addSubview:textView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithTweet:(NSDictionary *)tweet{
    
    NSDictionary *user = [tweet objectForKey:@"user"];
    NSString *profileImageURL = [user objectForKey:@"profile_image_url"];
    UIImage *userImage = [[JMImageCache sharedCache] imageForURL:profileImageURL delegate:self];
    NSString *text = [tweet objectForKey:@"text"];
    NSString *userName = [user objectForKey:@"name"];
    NSString *timestampStr = [tweet objectForKey:@"created_at"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
    NSDate *timestamp = [dateFormatter dateFromString:timestampStr];

    
    timestampLabel.text = [NSString stringWithFormat:@"%@, %@",userName,[timestamp agoStyleString]];
    timestampLabel.font = [UIFont boldSystemFontOfSize:11.0];
    timestampLabel.textColor = [UIColor darkGrayColor];
    timestampLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:.2];
    timestampLabel.shadowOffset = CGSizeMake(0, 1.0);
    timestampLabel.backgroundColor = [UIColor clearColor];
    
    userIcon.image = userImage;
    userIcon.layer.cornerRadius = 10.0;
    userIcon.clipsToBounds = YES;
    userIcon.layer.borderWidth = 1.0;
    userIcon.layer.borderColor = [UIColor colorWithWhite:0 alpha:.4].CGColor;
    userIcon.layer.shouldRasterize = YES;
    userIcon.contentScaleFactor = [[UIScreen mainScreen] scale];
    
    
    textView.backgroundColor = [UIColor clearColor];
    textView.text = text;
    [textView setNeedsDisplay];
}


-(void)setIsRightAligned:(BOOL)aligment{
    isRightAligned=aligment;
    textView.isRightAligned = aligment;
    if (aligment) {
        timestampLabel.textAlignment = UITextAlignmentRight;
    }
    else{
        timestampLabel.textAlignment = UITextAlignmentLeft;
    }
}


+(CGRect)imageRectInViewWithWidth:(CGFloat)superviewWidth withAlignment:(BOOL)isRightAligned{
    if(!isRightAligned){
        return CGRectMake(TWITTER_TABLE_PADDING,TWITTER_TABLE_PADDING,TWITTER_TABLE_IMAGE_SIZE, TWITTER_TABLE_IMAGE_SIZE);
    }
    return CGRectMake(superviewWidth - TWITTER_TABLE_IMAGE_SIZE - TWITTER_TABLE_PADDING , TWITTER_TABLE_PADDING, TWITTER_TABLE_IMAGE_SIZE, TWITTER_TABLE_IMAGE_SIZE);
}

+(CGRect)timestampRectInViewWithWidth:(CGFloat)superviewWidth withAlignment:(BOOL)isRightAligned{
    if (!isRightAligned) {
        return CGRectMake(TWITTER_TABLE_PADDING + TWITTER_TABLE_IMAGE_SIZE + TWITTER_TABLE_BUBBLE_TO_TEXT_SPACING, TWITTER_TABLE_PADDING, superviewWidth - TWITTER_TABLE_PADDING - TWITTER_TABLE_IMAGE_SIZE - TWITTER_TABLE_PADDING, TWITTER_TABLE_TIMESTAMP_HEIGHT);
    }
    return CGRectMake(TWITTER_TABLE_PADDING, TWITTER_TABLE_PADDING, superviewWidth - TWITTER_TABLE_BUBBLE_TO_TEXT_SPACING - TWITTER_TABLE_IMAGE_SIZE - 2.0 * TWITTER_TABLE_PADDING, TWITTER_TABLE_TIMESTAMP_HEIGHT);
}

+(CGFloat)heightForCellWithText:(NSString *)text inViewWithWidth:(CGFloat)superviewWidth{
    CGRect timestampRect = [[self class] timestampRectInViewWithWidth:superviewWidth withAlignment:NO];
    CGSize bubbleSize = [TextBubbleView sizeWithText:text inViewWithWidth:superviewWidth];
    return timestampRect.origin.y + timestampRect.size.height + bubbleSize.height;
}

-(void)layoutSubviews{
    CGRect imageRect = [[self class] imageRectInViewWithWidth:self.frame.size.width withAlignment:isRightAligned];
    CGRect timestampRect = [[self class] timestampRectInViewWithWidth:self.frame.size.width withAlignment:isRightAligned];
    CGSize textBubbleSize = [textView sizeThatFits:textView.frame.size];
    CGFloat xOriginBubble = timestampRect.origin.x;
    if (isRightAligned) {
        xOriginBubble = imageRect.origin.x - textBubbleSize.width;
    }
    CGFloat yOriginBubble = timestampRect.origin.y + timestampRect.size.height;
    textView.frame = CGRectMake(xOriginBubble, yOriginBubble, textBubbleSize.width, textBubbleSize.height);
    timestampLabel.frame = timestampRect;
    userIcon.frame = imageRect;
}



- (void) cache:(JMImageCache *)c didDownloadImage:(UIImage *)image forURL:(NSString *)url{
    userIcon.image = image;
}


-(NSString *)textOfTweet{
    return textView.text;
}

@end
