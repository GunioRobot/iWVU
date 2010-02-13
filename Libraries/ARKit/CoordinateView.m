//
//  CoordinateView.m
//  iPhoneAugmentedRealityLib
//
//  Created by Niels W Hansen on 12/19/09.
//  Copyright 2009 Agilite Software. All rights reserved.
//

#import "CoordinateView.h"
#import "ARCoordinate.h"

#define BOX_WIDTH 150
#define BOX_HEIGHT 100

@implementation CoordinateView


- (id)initForCoordinate:(ARCoordinate *)coordinate {
    	
	CGRect theFrame = CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT);
	
	if (self = [super initWithFrame:theFrame]) {
	
		UILabel *titleLabel	= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOX_WIDTH, 20.0)];
		
		[titleLabel setBackgroundColor: [UIColor colorWithWhite:.3 alpha:.8]];
		[titleLabel setTextColor:		[UIColor whiteColor]];
		[titleLabel setTextAlignment:	UITextAlignmentCenter];
		[titleLabel setText:			[coordinate title]];
		[titleLabel sizeToFit];
		[titleLabel setFrame:	CGRectMake(BOX_WIDTH / 2.0 - [titleLabel bounds].size.width / 2.0 - 4.0, 0, [titleLabel bounds].size.width + 8.0, [titleLabel bounds].size.height + 8.0)];
		
		UIImageView *pointView	= [[UIImageView alloc] initWithFrame:CGRectZero];
		[pointView setImage:	[UIImage imageNamed:@"location.png"]];
		[pointView setFrame:	CGRectMake((int)(BOX_WIDTH / 2.0 - [pointView image].size.width / 2.0), (int)(BOX_HEIGHT / 2.0 - [pointView image].size.height / 2.0), [pointView image].size.width, [pointView image].size.height)];
		
		[self addSubview:titleLabel];
		[self addSubview:pointView];
		[self setBackgroundColor:[UIColor clearColor]];
		[titleLabel release];
		[pointView release];
	}
	
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}


@end
