//
//  TTStyledLinkNode+URL.m
//  iWVU
//
//  Created by Jared Crawford on 2/26/10.
//  Copyright Jared Crawford 2010. All rights reserved.
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

#import "TTStyledTextLabel+URL.h"


@implementation TTStyledTextLabel (URL)




- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	TTTableView* tableView = (TTTableView*)[self ancestorOrSelfWithClass:[TTTableView class]];
	if (!tableView) {
		if (_highlightedNode) {
			// This is a dirty hack to decouple the UI from Style. TTOpenURL was originally within
			// the node implementation. One potential fix would be to provide some protocol for these
			// nodes to converse with.
			if ([_highlightedNode isKindOfClass:[TTStyledLinkNode class]]) {
				OPENURL([(TTStyledLinkNode*)_highlightedNode URL]);
				
			} else if ([_highlightedNode isKindOfClass:[TTStyledButtonNode class]]) {
				TTOpenURL([(TTStyledButtonNode*)_highlightedNode URL]);
				
			} else {
				[_highlightedNode performDefaultAction];
			}
			[self setHighlightedFrame:nil];
		}
	}
	
	// We definitely don't want to call this if the label is inside a TTTableView, because
	// it winds up calling touchesEnded on the table twice, triggering the link twice
	[super touchesEnded:touches withEvent:event];
}


@end
