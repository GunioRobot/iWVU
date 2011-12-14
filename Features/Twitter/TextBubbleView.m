//
//  TextBubbleView.m
//  USPTO
//
//  Created by Jared Crawford on 6/25/11.
//  Copyright 2011 Jared Crawford. All rights reserved.
//

#import "TextBubbleView.h"

@implementation TextBubbleView

@synthesize text;
@synthesize fontColor;
@synthesize isRightAligned;

#define TWITTER_BUBBLE_TEXT_INSET_LEFT_WHEN_LEFT_ALIGNED 10.0
#define TWITTER_BUBBLE_TEXT_INSET_RIGHT_WHEN_LEFT_ALIGNED 7.0
#define TWITTER_BUBBLE_TEXT_TOP_AND_BOTTOM_PADDING 3.0

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


+(UILineBreakMode)lineBreakModeForText{
    return UILineBreakModeWordWrap;
}

+(UIFont *)textFont{
    return [UIFont systemFontOfSize:12.0];
}

+(CGSize)sizeOfText:(NSString *)text inViewWithWidth:(CGFloat)superviewWidth{
    CGFloat maxPortionOfSuperview = .8;
    CGSize constrainedSize = CGSizeMake((superviewWidth*maxPortionOfSuperview) - TWITTER_BUBBLE_TEXT_INSET_LEFT_WHEN_LEFT_ALIGNED - TWITTER_BUBBLE_TEXT_INSET_RIGHT_WHEN_LEFT_ALIGNED, CGFLOAT_MAX);
    return [text sizeWithFont:[[self class] textFont] constrainedToSize:constrainedSize lineBreakMode:[[self class] lineBreakModeForText]];
    
}

+(CGSize)sizeWithText:(NSString *)text inViewWithWidth:(CGFloat)superviewWidth{
    CGSize textSize = [[self class] sizeOfText:text inViewWithWidth:superviewWidth];
    CGSize bubbleSize = CGSizeMake(textSize.width + TWITTER_BUBBLE_TEXT_INSET_RIGHT_WHEN_LEFT_ALIGNED + TWITTER_BUBBLE_TEXT_INSET_LEFT_WHEN_LEFT_ALIGNED, textSize.height + 2.0 * TWITTER_BUBBLE_TEXT_TOP_AND_BOTTOM_PADDING);
    CGSize minSize = CGSizeMake(80.0, 40.0);
    return CGSizeMake(MAX(bubbleSize.width, minSize.width), MAX(bubbleSize.height, minSize.height));
}


-(UIEdgeInsets)resizableImageInset{
    return UIEdgeInsetsMake(20.0, 20.0, 19.0, 19.0);
}

-(UIImage *)bubbleImage{
    if (!isRightAligned) {
        return [[UIImage imageNamed:@"BubbleLeft"] resizableImageWithCapInsets:[self resizableImageInset]];
    }
    return [[UIImage imageNamed:@"BubbleRight"] resizableImageWithCapInsets:[self resizableImageInset]];
}

-(CGSize)sizeThatFits:(CGSize)size{
    return [[self class] sizeWithText:self.text inViewWithWidth:self.superview.bounds.size.width];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect{
    UIEdgeInsets inset;
    if(isRightAligned){
        inset = UIEdgeInsetsMake(TWITTER_BUBBLE_TEXT_TOP_AND_BOTTOM_PADDING, TWITTER_BUBBLE_TEXT_INSET_RIGHT_WHEN_LEFT_ALIGNED, TWITTER_BUBBLE_TEXT_TOP_AND_BOTTOM_PADDING, TWITTER_BUBBLE_TEXT_INSET_LEFT_WHEN_LEFT_ALIGNED);
    }
    else {
        inset = UIEdgeInsetsMake(TWITTER_BUBBLE_TEXT_TOP_AND_BOTTOM_PADDING, TWITTER_BUBBLE_TEXT_INSET_LEFT_WHEN_LEFT_ALIGNED, TWITTER_BUBBLE_TEXT_TOP_AND_BOTTOM_PADDING, TWITTER_BUBBLE_TEXT_INSET_RIGHT_WHEN_LEFT_ALIGNED);
    }
    
    CGSize textSize = [[self class] sizeOfText:self.text inViewWithWidth:self.superview.frame.size.width];
    [[self bubbleImage] drawInRect:self.bounds];
    [self.fontColor set];
    [self.text drawInRect:CGRectMake(inset.left, inset.top, textSize.width, textSize.height) withFont:[[self class] textFont] lineBreakMode:[[self class] lineBreakModeForText]];
    //[self.text drawAtPoint:CGPointMake(inset.left, inset.top) forWidth:textSize.width withFont:[self textFont] lineBreakMode:[self lineBreakModeForText]];
}

@end
