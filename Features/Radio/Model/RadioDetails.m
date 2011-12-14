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
	@autoreleasepool {
		NSStringEncoding enc;
		NSError *err;
		NSURL *path = [NSURL URLWithString:@"http://u92.wvu.edu"]; 
		NSString *webContents = [NSString stringWithContentsOfURL:path usedEncoding:&enc error:&err];
		
		if(websiteStr){
			websiteStr = nil;
		}
		
		
		if (webContents && ![[NSThread currentThread] isCancelled]) {
			websiteStr = webContents;
		}
		
		self.currentShow = [self parseCurrentShow];
		backgroundThread = nil;
	}
}


-(void)dealloc{
	[backgroundThread cancel];
}

-(id)init{
	if (self = [super init]) {
		[self refresh];
	}
	return self;
}




@end
