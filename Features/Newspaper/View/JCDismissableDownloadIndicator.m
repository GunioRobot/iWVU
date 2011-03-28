//
//  JCDismissableDownloadIndicator.m
//  iWVU
//
//  Created by Jared Crawford on 10/23/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "JCDismissableDownloadIndicator.h"


@implementation JCDismissableDownloadIndicator
@synthesize delegate;

- (id) initWithProgressTitle:(NSString*)txt{
	if (self = [super initWithProgressTitle:txt]) {
		displaysDownloadStatus = YES;
	}
	return self;
}


- (id) initWithProgressTitleButNoProgressBar:(NSString*)txt{
	if (self = [super initWithProgressTitle:txt]) {
		displaysDownloadStatus = NO;
	}
	return self;
}

- (TKProgressBarView *) progressBar{
	if (!displaysDownloadStatus) {
		return nil;
	}
	return [super progressBar];
}


- (void) show{
	[super show];
	[self addSubview:self.dismissalButton];
	if (!displaysDownloadStatus) {
		label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y + 15, label.frame.size.width, label.frame.size.height);
	}
}


-(void)dismiss{
	[delegate downloadIndicatorDismissed:self];
	[self hide];
}

-(TTButton *)dismissalButton{
	//refer to [TTLauncherButton closeButton] for more on this function
	if (!_dismissalButton) {
		_dismissalButton = [[TTButton buttonWithStyle:@"launcherCloseButton:"] retain];
		[_dismissalButton setImage:@"bundle://Three20.bundle/images/closeButton.png"
						  forState:UIControlStateNormal];
		//_dismissalButton.size = CGSizeMake(26,29);
		_dismissalButton.frame = CGRectMake(-5,-7, 26, 29);
		_dismissalButton.isVertical = YES;
		[_dismissalButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
	}
	return _dismissalButton;
}

- (void) drawRect:(CGRect)rect{
	//beginning with iOS 4.2, UIAlertView doesn't use drawRect to draw the blue box.
    //[super drawRect:rect]; would have replaced the blue box pre 4.2, but now it overlays it
    //by overriding drawRect, I can add things to the alertView blue box
}

-(void)dealloc{
	[_dismissalButton release];
	[super dealloc];
}

@end
