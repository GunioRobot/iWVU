//
//  TTDefaultStyleSheet+MainScreenLauncher.m
//  iWVU
//
//  Created by Jared Crawford on 1/2/10.
//  Copyright Jared Crawford 2009. All rights reserved.
//

/*
 Copyright (c) 2009 Jared Crawford
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 The trademarks owned or managed by the West Virginia 
 University Board of Governors (WVU) are used under agreement 
 between the above copyright holder(s) and WVU. The West 
 Virginia University Board of Governors maintains ownership of all 
 trademarks. Reuse of this software or software source code, in any 
 form, must remove all references to any trademark owned or 
 managed by West Virginia University.
 */ 

#import "TTDefaultStyleSheet+MainScreenLauncher.h"


@implementation TTDefaultStyleSheet (MainScreenLauncher)

- (TTStyle*)mainScreenLauncherButton:(UIControlState)state {
	return
    [TTPartStyle styleWithName:@"image" style:TTSTYLESTATE(launcherButtonImage:, state) next:
	 [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:16] color:[UIColor WVUBlueColor]
				minimumFontSize:11 shadowColor:nil
				   shadowOffset:CGSizeZero next:nil]];
}

- (TTStyle*)pageDotWithColor:(UIColor*)color {
	
	if ([color isEqual:[UIColor whiteColor]]) {
		color = [UIColor WVUBlueColor];
	}
	else {
		color = [UIColor colorWithRed:0 green:.2 blue:.4 alpha:.5];
	}

	
	
	
	return
    [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(0,0,0,10) padding:UIEdgeInsetsMake(6,6,0,0) next:
	 [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:2.5] next:
	  [TTSolidFillStyle styleWithColor:color next:nil]]];
}

@end
