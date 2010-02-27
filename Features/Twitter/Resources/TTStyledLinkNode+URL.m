//
//  TTStyledLinkNode+URL.m
//  iWVU
//
//  Created by Jared Crawford on 2/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TTStyledLinkNode+URL.h"


@implementation TTStyledLinkNode (URL)

- (void)performDefaultAction {
	if (_URL) {
		OPENURL(_URL)
	}
}

@end
