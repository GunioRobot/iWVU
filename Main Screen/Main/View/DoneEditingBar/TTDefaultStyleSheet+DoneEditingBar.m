//
//  TTDefaultStyleSheet+DoneEditingBar.m
//  iWVU
//
//  Created by Jared Crawford on 1/12/10.
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
