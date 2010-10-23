//
//  JCLoadingView.h
//  iWVU
//
//  Created by Jared Crawford on 10/12/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TapkuLibrary/TapkuLibrary.h>


@interface JCLoadingView : TKLoadingView {
	NSString *nextMessage;
	NSString *nextTitle;
}

-(void)showLoadingView;
-(void)showLoadingViewInView:(UIView *)parentView;
-(void)dismissLoadingView;
-(void)dismissLoadingViewAndReappearWithTitle:(NSString *)newTitle andMessage:(NSString *)newMessage;

@end
