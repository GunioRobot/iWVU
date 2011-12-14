//
//  NewspaperEngine.m
//  iWVU
//
//  Created by Jared Crawford on 2/9/10.
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

#import "NewspaperEngine.h"
#import "NSDate+StringCalendarDate.h"
#import "UIImage-NSCoding.h"


@interface NewspaperEngine (Private)

-(void)downloadPage:(int)page onDate:(NSDate *)aDate;
-(void)downloadPageWithParams:(NSArray *)params;
-(NSString *)urlForPage:(int)page onDate:(NSDate *)aDate;
-(NSString *)storagePathForPage:(int)page onDate:(NSDate *)aDate;
-(BOOL)cachedPage:(int)page existForDate:(NSDate *)aDate;
-(void)storePage:(UIImage *)page withNumber:(int)pageNumber forDate:(NSDate *)date;

@end



@implementation NewspaperEngine

@synthesize delegate;
@synthesize currentDate;
@synthesize requestedDate;


-(id)initWithDelegate:(id<NewspaperEngineDelegate>)aDelegate{
	if (self = [super init]) {
		self.delegate = aDelegate;
		numberOfPagesForDate = [self getNumberOfPagesDictionary];
		if(!numberOfPagesForDate){
			numberOfPagesForDate = [[NSMutableDictionary alloc] init];
		}
		currentlyRunningThreads = [[NSMutableArray alloc] init];
	}
	return self;
}





-(void)downloadPagesForDate:(NSDate *)aDate{
	
	if(stillDownloading){
		//the last download was still in progress
		[numberOfPagesForDate removeObjectForKey:[requestedDate calendarDateString]];
		[self storeNumberOfPagesDictionary];
	}
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if([[userDefaults stringForKey:USER_DEFAULT_NEWSPAPER_CACHE_KEY] isEqualToString:USER_DEFAULT_NEWSPAPER_CACHE_NEGATIVE]){
		//the user has specified that they don't want cached pages
		//by placing clear here, it ensures that a maximum of 1 edition is cached at any time
		//this one cached page is the "current" page, which is being displayed
		[self clearAllLocallyCachedPages];
	}
	
	
	self.requestedDate = aDate;
	stillDownloading = YES;
	int pageNum = 0;
	
	//Look in the cache first, no need to redownload if it already exists
	pageNum = [[numberOfPagesForDate valueForKey:[aDate calendarDateString]] intValue];
	
	if(pageNum == 0){
		//we didn't have any cached pages
		[self downloadPage:1 onDate:aDate];
	}
	else{
		//we did have cached pages, so don't download any more
		stillDownloading = NO;
		[delegate newDataAvailable];
	}
}
		

-(void)downloadPage:(int)page onDate:(NSDate *)aDate{
	if([aDate isEqualToDate:requestedDate]){
		NSArray *params = [NSArray arrayWithObjects:[NSNumber numberWithInt:page], aDate, nil];
		NSThread *aThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadPageWithParams:) object:params];
		[aThread start];
		[currentlyRunningThreads addObject:aThread];
	}
}

-(void)downloadPageWithParams:(NSArray *)params{
	@autoreleasepool {
	
	//unarchive params
		int page = [[params objectAtIndex:0] intValue];
		NSDate *aDate = [params objectAtIndex:1];
		
		NSURL *url = [NSURL URLWithString:[self urlForPage:page onDate:aDate]];
		NSData *data = [NSData dataWithContentsOfURL:url];
		UIImage *img = [UIImage imageWithData:data];
		if(![[NSThread currentThread] isCancelled]){
			if((img!=nil) && (page<40)){
				stillDownloading = YES;
				//store the page
				[self storePage:img withNumber:page forDate:aDate];
				//and try to download another page
				[self downloadPage:(page+1) onDate:aDate];
				[numberOfPagesForDate setObject:[NSNumber numberWithInt:page] forKey:[aDate calendarDateString]];
				[self storeNumberOfPagesDictionary];
			}
			else{
				//we've either found the last page, or we've exceeded our limit
				stillDownloading = NO;
				[numberOfPagesForDate setObject:[NSNumber numberWithInt:(page-1)] forKey:[aDate calendarDateString]];
				[self storeNumberOfPagesDictionary];
			}
			
			if([aDate isEqualToDate:requestedDate]){
				//we're not done yet, but we should report this page to the delegate
				if (![[NSThread currentThread] isCancelled]) {
					[(id)delegate performSelectorOnMainThread:@selector(newDataAvailable) withObject:nil waitUntilDone:NO];
				}
			}
			else{
				//the downloading was interupted half way through.
				//we don't want the cached pages to be used, beacuse they are not complete
				[numberOfPagesForDate removeObjectForKey:[aDate calendarDateString]];
				[self storeNumberOfPagesDictionary];
			}
		}

	}
}


-(NSString *)urlForPage:(int)page onDate:(NSDate *)aDate{
	NSString *baseURL = @"http://www.wvu.edu/~wvuda/";
	NSString *editionDate = [[aDate description] substringToIndex:10]; 
	NSString *pageURL = [NSString stringWithFormat:@"%@%@/Page%@%d.jpg",baseURL,editionDate,@"%20",page];
	NSLog(@"%@", pageURL);
	return pageURL;
}


-(NSString *)directoryForPages{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES); 
	NSString *aPath = [paths objectAtIndex:0];
	aPath = [aPath stringByAppendingPathComponent:@"Newspaper"];
	aPath = [aPath stringByExpandingTildeInPath];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if([fileManager contentsOfDirectoryAtPath:aPath error:NULL] == nil){
		//the directory doesn't exist
		[fileManager createDirectoryAtPath:aPath withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	return aPath;
}

-(NSString *)storagePathForPage:(int)page onDate:(NSDate *)aDate{
	NSString *aPath = [self directoryForPages];
	aPath = [aPath stringByAppendingPathComponent:[aDate calendarDateString]];
	return [aPath stringByAppendingFormat:@"Page%d.jpg",page];
}



-(BOOL)cachedPage:(int)page existForDate:(NSDate *)aDate{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:[self storagePathForPage:page onDate:aDate]];	
}

-(BOOL)isStillDownloading{
	return stillDownloading;
}


-(void)cancelDownloads{
	//stop running threads
	for(NSThread *aThread in currentlyRunningThreads){
		[aThread cancel];
	}
	[currentlyRunningThreads removeAllObjects];
	if(stillDownloading){
		[numberOfPagesForDate removeObjectForKey:[requestedDate calendarDateString]];
		[self storeNumberOfPagesDictionary];
	}
}



-(int)numberOfPagesForDate:(NSDate *)date{
	return [[numberOfPagesForDate objectForKey:[date calendarDateString]] intValue];
}

-(void)clearAllLocallyCachedPages{
	NSString *aPath = [self directoryForPages];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *err;
	[fileManager removeItemAtPath:aPath error:&err];
	if(err){
		NSLog(@"File Clearing error occured");
	}
	numberOfPagesForDate = [[NSMutableDictionary alloc] init];
	[self storeNumberOfPagesDictionary];
}



-(UIImage *)getPage:(int)pageNum forDate:(NSDate *)date{
	NSString *path = [self storagePathForPage:pageNum onDate:date];
	NSData *data = [NSData dataWithContentsOfFile:path];
	UIImage *img = [UIImage imageWithData:data];
	if(img == nil){
		NSLog(@"Loading Page Failed. Path: %@", path);
	}
	return img;
}

-(void)storePage:(UIImage *)page withNumber:(int)pageNumber forDate:(NSDate *)date{
	NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(page,1.0)];
	NSString *path = [self storagePathForPage:pageNumber onDate:date];
	//NSLog(path);
	BOOL writeStatus = [data writeToFile:path atomically:YES];
	if(writeStatus == NO){
		NSLog(@"Write Page Failed. Path: %@", path);
	}
}


-(NSString *)pathForPagesDictionary{
	NSString *aPath = [self directoryForPages];
	aPath = [aPath stringByAppendingPathComponent:@"PagesDictionary"];
	return aPath;
}

-(void)storeNumberOfPagesDictionary{
	NSString *aPath = [self pathForPagesDictionary];
	BOOL writeStatus = [NSKeyedArchiver archiveRootObject:numberOfPagesForDate toFile:aPath];
	if(writeStatus == NO){
		NSLog(@"Write Dictionary Failed. Path: %@", aPath);
	}
}

-(NSMutableDictionary *)getNumberOfPagesDictionary{
	NSString *aPath = [self pathForPagesDictionary];
	NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithFile:aPath];
	if(!dict){
		NSLog(@"Dictionary not found. Path: %@", aPath);
	}
	return dict;
}

@end
