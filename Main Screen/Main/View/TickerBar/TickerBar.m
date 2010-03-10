//
//  TickerBar.m
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

#import "TickerBar.h"


@implementation TickerBar

@synthesize delegate;
@synthesize rssURL;
@synthesize feedName;

-(UILabel *)getLabel{
	return _label;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if (event.type == UIEventTypeTouches) {
		for (FPItem *newsItem in newsFeed.items) {
			if ([newsItem.title isEqualToString:[self getLabel].text]) {
				[delegate tickerBar:self itemSelected:newsItem.link.href];
			}
		}
	}
}



-(id)initWithURL:(NSURL *)aURL andFeedName:(NSString *)aFeedName{
	self = [[TickerBar alloc] initWithStyle:TTActivityLabelStyleBlackBanner];
	self.rssURL = aURL;
	self.feedName = aFeedName;
	self.text = [NSString stringWithFormat:@"%@ Loading...", feedName];
	self.clipsToBounds = YES;
	return self;
}


-(void)startTicker{
	tickerIsPaused = NO;
	if(newsFeed){
		[self displayTickerBarItem];
	}
	else if (rssURL) {
		NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadRSSFeed) object:nil];
		[thread start];
		[thread release];
	}
}



-(void)downloadRSSFeed{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//NSString *rssURL = @"http://wvutoday.wvu.edu/n/rss/";
	//http://reader.mac.com/mobile/v1/http%3A%2F%2Fwvutoday.wvu.edu%2Fn%2Frss%2F
	NSData *data = [NSData dataWithContentsOfURL:rssURL];
	NSError *err;
	FPFeed *aFeed = [FPParser parsedFeedWithData:data error:&err];
	if ((!data)||(!aFeed)) {
		newsFeed = nil;
		[self performSelectorOnMainThread:@selector(downloadOfRSSFailed) withObject:nil waitUntilDone:NO];
		//break
	}
	else {
		newsFeed = [aFeed retain];
		[self performSelectorOnMainThread:@selector(displayTickerBarItem) withObject:nil waitUntilDone:NO];
	}
	[pool release];
	
}

-(void)downloadOfRSSFailed{
	self.isAnimating = NO;
	self.text = [NSString stringWithFormat:@"%@ Unavailable", feedName];
}


-(void)willMoveToWindow:(UIWindow *)newWindow{
	if(!newWindow){
		[self pauseTicker];
	}
	else if(tickerIsPaused){
		[self startTicker];
	}
}

-(void)pauseTicker{
	tickerIsPaused = YES;
}

-(void)displayTickerBarItem{
	if(tickerIsPaused){
		return;
	}
	if (newsFeed){
		
		static int currentItem = -1;
		currentItem++;
		if (currentItem >= [newsFeed.items count]) {
			currentItem = 0;
		}
		
		FPItem *newsItem = [newsFeed.items objectAtIndex:currentItem];
		self.isAnimating = NO;
		UILabel *label = [self getLabel];
		
		
		label.text = newsItem.title;
		CGSize size = [label.text sizeWithFont:label.font];
		float padding= 5;
		float stopPosition = (self.bounds.size.width-size.width)/2.0;
		if (size.width > self.bounds.size.width) {
			stopPosition = -1.0*(size.width - self.bounds.size.width)-padding;
		}
		
		label.frame = CGRectMake(stopPosition, label.frame.origin.y, size.width, size.height);
		[label slideInFrom:kFTAnimationRight duration:TICKER_ANIMATION_DURATION delegate:self startSelector:nil stopSelector:@selector(holdTickerBarItem)];
	}
}

-(void)holdTickerBarItem{
	if(tickerIsPaused){
		return;
	}
	
	[self performSelector:@selector(removeTickerBarItem) withObject:nil afterDelay:TICKER_WAIT_DURATION];
	
}

-(void)removeTickerBarItem{
	if(tickerIsPaused){
		return;
	}
	UILabel *label = [self getLabel];
	[label slideOutTo:kFTAnimationLeft duration:TICKER_REMOVE_DURATION delegate:self startSelector:nil stopSelector:@selector(displayTickerBarItem)];
	
}

@end
