//
//  DoneEditingBar.m
//  iWVU
//
//  Created by Jared Crawford on 1/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DoneEditingBar.h"
#import "TTDefaultStyleSheet+DoneEditingBar.h"


@implementation DoneEditingBar

@synthesize delegate;

+(DoneEditingBar *)createBar{
	
	DoneEditingBar *aBar = [[DoneEditingBar alloc] initWithStyle:TTActivityLabelStyleBlackBanner];
	aBar.text = @"Tap here to end editing.";
	aBar.isAnimating = NO;
	[aBar setStyle];
	return [aBar autorelease];
	
}

-(void)setStyle{
	_bezelView.style = TTSTYLE(doneEditingBannerStyle);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if (event.type == UIEventTypeTouches) {
		[delegate doneEditingBarHasFinished:self];
	}
}

@end
