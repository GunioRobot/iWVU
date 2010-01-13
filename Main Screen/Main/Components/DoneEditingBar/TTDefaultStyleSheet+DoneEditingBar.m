//
//  TTDefaultStyleSheet+DoneEditingBar.m
//  iWVU
//
//  Created by Jared Crawford on 1/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TTDefaultStyleSheet+DoneEditingBar.h"


@implementation TTDefaultStyleSheet (DoneEditingBar)

- (TTStyle*)doneEditingBannerStyle {
	UIColor *barColor = [UIColor colorWithRed:0 green:.2 blue:.4 alpha:1];
	
	return
    [TTSolidFillStyle styleWithColor:barColor next:
	 [TTFourBorderStyle styleWithTop:RGBCOLOR(0, 0, 0) right:nil bottom:nil left: nil width:1 next:
	  [TTFourBorderStyle styleWithTop:[UIColor colorWithWhite:1 alpha:0.2] right:nil bottom:nil
								 left: nil width:1 next:nil]]];
}


@end
