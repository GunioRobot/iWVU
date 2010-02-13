//
//  NewspaperEngine.m
//  iWVU
//
//  Created by Jared Crawford on 2/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NewspaperEngine.h"
#import "NSDate+Helper.h"
#import "UIImage-NSCoding.h"


@interface NewspaperEngine (Private)

-(void)downloadPage:(int)page onDate:(NSDate *)aDate storeIn:(NSMutableArray *)storageArray;
-(void)downloadPageWithParams:(NSArray *)params;
-(NSString *)urlForPage:(int)page onDate:(NSDate *)aDate;
-(NSString *)storagePathForPage:(int)page onDate:(NSDate *)aDate;
-(BOOL)cachedPage:(int)page ExistForDate:(NSDate *)aDate;

@end



@implementation NewspaperEngine

@synthesize delegate;
@synthesize downloadedPages;
@synthesize currentDate;
@synthesize requestedDate;


-(id)initWithDelegate:(id<NewspaperEngineDelegate>)aDelegate{
	if (self = [super init]) {
		self.delegate = aDelegate;
	}
	return self;
}



-(void)downloadPagesForDate:(NSDate *)aDate{
	self.requestedDate = aDate;
	stillDownloading = YES;
	NSMutableArray *temporaryPages = [[NSMutableArray array] retain];
	int pageNum = 1;
	
	//Look in the cache first, no need to redownload if it already exists
	/*
	 while([self cachedPage:pageNum ExistForDate:aDate]){
		[temporaryPages addObject:[NSKeyedUnarchiver unarchiveObjectWithFile:[self storagePathForPage:pageNum onDate:aDate]]];
		pageNum++;
	}
	 */
	
	if(pageNum == 1){
		[self downloadPage:1 onDate:aDate storeIn:temporaryPages];
	}
}
		

-(void)downloadPage:(int)page onDate:(NSDate *)aDate storeIn:(NSMutableArray *)storageArray{
	if([aDate isEqualToDate:requestedDate]){
		NSArray *params = [NSArray arrayWithObjects:[NSNumber numberWithInt:page], aDate, storageArray, nil];
		NSThread *aThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadPageWithParams:) object:params];
		[aThread start];
		[aThread release];
	}
	else{
		[storageArray release];
	}
}

-(void)downloadPageWithParams:(NSArray *)params{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	//unarchive params
	int page = [[params objectAtIndex:0] intValue];
	NSDate *aDate = [params objectAtIndex:1];
	NSMutableArray *storageArray = [params objectAtIndex:2];
	
	NSURL *url = [NSURL URLWithString:[self urlForPage:page onDate:aDate]];
	NSData *data = [NSData dataWithContentsOfURL:url];
	UIImage *img = [UIImage imageWithData:data];
	if((img!=nil) && (page<40)){
		stillDownloading = YES;
		[storageArray addObject:img];
		[self downloadPage:(page+1) onDate:aDate storeIn:storageArray];
		//[NSKeyedArchiver archiveRootObject:img toFile:[self storagePathForPage:page	onDate:aDate]];
	}
	else{
		stillDownloading = NO;
	}
	if([aDate isEqualToDate:requestedDate]){
		self.downloadedPages = [NSArray arrayWithArray:storageArray];
		self.currentDate = aDate;
		[(id)delegate performSelectorOnMainThread:@selector(newDataAvailable) withObject:nil waitUntilDone:NO];
	}
	[pool release];
}


-(NSString *)urlForPage:(int)page onDate:(NSDate *)aDate{
	NSString *baseURL = @"http://www.wvu.edu/~wvuda/";
	NSString *editionDate = [[aDate description] substringToIndex:10]; 
	return [NSString stringWithFormat:@"%@%@/Page%@%d.jpg",baseURL,editionDate,@"%20",page];
}

-(NSString *)storagePathForPage:(int)page onDate:(NSDate *)aDate{
	NSString *aPath = NSTemporaryDirectory();
	aPath = [aPath stringByAppendingPathComponent:@"Newspaper"];
	aPath = [aPath stringByAppendingPathComponent:[NSDate stringFromDate:aDate withFormat:@"yyyy-MM-dd"]];
	return [aPath stringByAppendingFormat:@"Page%d.jpg",page];
}



-(BOOL)cachedPage:(int)page ExistForDate:(NSDate *)aDate{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:[self storagePathForPage:page onDate:aDate]];	
}

-(BOOL)isStillDownloading{
	return stillDownloading;
}

@end
