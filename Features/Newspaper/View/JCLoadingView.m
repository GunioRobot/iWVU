//
//  JCLoadingView.m
//  iWVU
//
//  Created by Jared Crawford on 10/12/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "JCLoadingView.h"

@interface JCLoadingView (Private)
-(void)animationStep1;
- (void) animationStep2WithStopSelector:(SEL)stopSelector;

@end






@implementation JCLoadingView


- (void) showLoadingView{
	[self showLoadingViewInView:[UIApplication sharedApplication].keyWindow];
}


-(void)showLoadingViewInView:(UIView *)parentView{
	[self startAnimating];
	self.transform = CGAffineTransformIdentity;
	self.alpha = 0;
	[parentView addSubview:self];
	self.center = parentView.center;
	[self animationStep1];
}

-(void)animationStep1{
	self.transform = CGAffineTransformMakeScale(2, 2);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.15];
	self.transform = CGAffineTransformIdentity;
	self.alpha = 1;
	[UIView commitAnimations];
}

-(void)dismissLoadingView{
	[self animationStep2WithStopSelector:@selector(removeMe)];
}

- (void) animationStep2WithStopSelector:(SEL)stopSelector{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:stopSelector];
	self.transform = CGAffineTransformMakeScale(0.5, 0.5);
	self.alpha = 0;
	[UIView commitAnimations];
}
- (void) removeMe{
	[self removeFromSuperview];
}


-(void)dismissLoadingViewAndReappearWithTitle:(NSString *)newTitle andMessage:(NSString *)newMessage{
	[self animationStep2WithStopSelector:@selector(loadANewOne)];
	nextTitle = newTitle;
	nextMessage = newMessage;
}

-(void)loadANewOne{
	self.title = nextTitle;
	self.message = nextMessage;
	nextTitle = nil;
	nextMessage = nil;
	[self animationStep1];
}



@end
