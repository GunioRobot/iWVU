//
//  TextBubbleView.h
//  USPTO
//
//  Created by Jared Crawford on 6/25/11.
//  Copyright 2011 Jared Crawford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextBubbleView : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic) BOOL isRightAligned;

+(CGSize)sizeWithText:(NSString *)text inViewWithWidth:(CGFloat)superviewWidth;

@end
