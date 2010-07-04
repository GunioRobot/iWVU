//
//  RadioDetails.m
//  iWVU
//
//  Created by Jared Crawford on 6/26/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "RadioDetails.h"


@implementation RadioDetails

@synthesize currentShow;

-(void)refresh{
	if (!backgroundThread) {
		NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadedDownloadOfWebContent) object:nil];
		[thread start];
		[thread release];
	}
}


-(NSString *)parseCurrentShow{
	//Now Playing:&nbsp;&nbsp;<b>Alternative Music</b></TD>
	if (websiteStr) {
		NSRange start = [websiteStr rangeOfString:@"Now Playing:&nbsp;&nbsp;<b>"];
		int genreStart = start.location + start.length;
		NSString *substring = [websiteStr substringFromIndex:genreStart];
		NSRange end = [substring rangeOfString:@"</b>"];
		return [substring substringToIndex:end.location];
	}
	return NO_U92_ERROR_STR;
}

-(void)threadedDownloadOfWebContent{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSStringEncoding enc;
	NSError *err;
	NSURL *path = [NSURL URLWithString:@"http://u92.wvu.edu"]; 
	NSString *webContents = [NSString stringWithContentsOfURL:path usedEncoding:&enc error:&err];
	
	if(websiteStr){
		[websiteStr release];
		websiteStr = nil;
	}
	
	
	if (webContents && ![[NSThread currentThread] isCancelled]) {
		websiteStr = [webContents retain];
	}
	
	self.currentShow = [self parseCurrentShow];
	backgroundThread = nil;
	[pool release];
}


-(void)dealloc{
	[backgroundThread cancel];
	[super dealloc];
}

-(id)init{
	if (self = [super init]) {
		[self refresh];
	}
	return self;
}




@end
