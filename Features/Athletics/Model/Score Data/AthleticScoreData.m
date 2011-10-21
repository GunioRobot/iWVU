//
//  AthleticScoreData.m
//  iWVU
//
//  Created by Jared Crawford on 12/18/09.
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

#import "AthleticScoreData.h"
#import "UIImage-NSCoding.h"
#import "CJSONDeserializer.h"

@implementation AthleticScoreData

@synthesize delegate;
@synthesize dataURL;
@synthesize downloadedGameData;
@synthesize gameIsInProgress;
@synthesize timeStamp;
@synthesize homeLogos;
@synthesize awayLogos;
@synthesize tempHomeLogos;
@synthesize tempAwayLogos;
@synthesize imageDownloadThreads;
@synthesize mainDataRequestThread;

-(id)init{
	[super init];
	self.downloadedGameData = [NSArray array];
	gameIsInProgress = NO;
	numOfImagesAwaitingDowload = 0;
	return self;
}

-(id)initWithTeam:(AthleticsTeam)team{
	if (self = [super init]) {
		if(team==AthleticsTeamFootball){
			self.dataURL = @"http://m.wvu.edu/gameday/json/index.php?team=fb";
		}
		else if(team==AthleticsTeamMensBasketball){
			self.dataURL = @"http://m.wvu.edu/gameday/json/index.php?team=mbb";
		}
		else if(team==AthleticsTeamWomensBasketball){
			self.dataURL = @"http://m.wvu.edu/gameday/json/index.php?team=wbb";
		}
	}
	return self;
}
						
-(NSString *)stringForKey:(NSString *)key inDict:(NSDictionary *)dict{
	NSString *value = [dict objectForKey:key];
	if (value != nil) {
		return value;
	}
	return @"";
}


-(void)getImages{
	self.tempHomeLogos = [NSMutableArray arrayWithCapacity:[downloadedGameData count]];
	self.tempAwayLogos = [NSMutableArray arrayWithCapacity:[downloadedGameData count]];
	self.imageDownloadThreads = [NSMutableArray arrayWithCapacity:[downloadedGameData count]];
	removeThreadLock = [[NSLock alloc] init];
	for(int i=0;i<[downloadedGameData count];i++){
		NSThread *imageThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadGameImages:) object:[NSNumber numberWithInt:i]];
		[imageDownloadThreads addObject:imageThread];
		[imageThread release];
	}
	
	for(NSThread *imageThread in imageDownloadThreads){
		[imageThread start];
	}
	
}

-(void)downloadGameImages:(NSNumber *)index{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *awayURLStr = [[downloadedGameData objectAtIndex:[index intValue]] valueForKey:@"awayLogo"];
	NSString *homeURLStr = [[downloadedGameData objectAtIndex:[index intValue]] valueForKey:@"homeLogo"];
	
	UIImage *awayimg = nil;
	UIImage *homeimg = nil;
	
	if(![[NSThread currentThread] isCancelled]){
		NSData *awayimgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:awayURLStr]];
		awayimg = [UIImage imageWithData:awayimgData];
	}
	if(![[NSThread currentThread] isCancelled]){
		NSData *homeimgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:homeURLStr]];
		homeimg = [UIImage imageWithData:homeimgData];
	}
	
	
	if(!awayimg){
		awayimg = [UIImage imageNamed:@"NCAA_Logo.png"];
	}
	if(!homeimg){
		awayimg = [UIImage imageNamed:@"NCAA_Logo.png"];
	}
	
	//go ahead and retain autoreleased images before this blocking loop
	[homeimg retain];
	[awayimg retain];
	
	//blocking loop until all images before have filled
	BOOL allGamesBeforeThisOneHaveFilled = NO;
	BOOL thisThreadIsCurrentlyActive = YES;
	
	while(!allGamesBeforeThisOneHaveFilled && thisThreadIsCurrentlyActive){
		if([[NSThread currentThread] isCancelled]){
			thisThreadIsCurrentlyActive = NO;
		}
		else if([tempAwayLogos count] == [index intValue]){
			allGamesBeforeThisOneHaveFilled = YES;
		}
	}
		
	if(![[NSThread currentThread] isCancelled]){
		
		[tempAwayLogos addObject:awayimg];
		[tempHomeLogos addObject:homeimg];
		
		//a hack to prevent simulator crashes
		//[NSMutableArray removeObject:] does not appear to be thread safe
		//must use an NSLock to prevent crashes
		[removeThreadLock lock];
		[imageDownloadThreads removeObject:[NSThread currentThread]];
		if([imageDownloadThreads count]==0){
			[self finalizeImageArrays];
			[removeThreadLock unlock];
			[removeThreadLock release];
			removeThreadLock = nil;
		}
		[removeThreadLock unlock];
		
		
	}
	
	
	//now you can release images
	[homeimg release];
	[awayimg release];
	
	
	[pool release];
}




-(void)finalizeImageArrays{
	self.homeLogos = [NSArray arrayWithArray:tempHomeLogos];
	self.awayLogos = [NSArray arrayWithArray:tempAwayLogos];
	
	self.tempAwayLogos = nil;
	self.tempHomeLogos = nil;
	
	self.imageDownloadThreads = nil;
	
	[self informDelegateOfNewData];
}


-(void)requestScoreData{
	//immediately return data
	self.downloadedGameData = [self loadData];
	[self informDelegateOfNewData];
	
	self.mainDataRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(startDownloadingData) object:nil];
	[mainDataRequestThread start];
	[mainDataRequestThread release];
}

-(void)startDownloadingData{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSError *err;
	NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dataURL]];
	NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&err];
	if(dict){
		if(![[NSThread currentThread] isCancelled]){
			self.downloadedGameData = [dict objectForKey:@"data"];
			[self informDelegateOfNewData];
			[self performSelectorOnMainThread:@selector(getImages) withObject:nil waitUntilDone:NO];
		}
	}
	
	self.mainDataRequestThread = nil;
	
	[pool release];
	 
}

-(void)informDelegateOfNewData{
	if ([((id)delegate) respondsToSelector:@selector(newScoreDataAvailable)]) {
		[self saveData:downloadedGameData];
		[(id)delegate performSelectorOnMainThread:@selector(newScoreDataAvailable) withObject:nil waitUntilDone:NO];
	}
}




-(void)cancelAllDownloads{
	if(mainDataRequestThread){
		[mainDataRequestThread cancel];
	}
	if(imageDownloadThreads){
		for(NSThread *thread in imageDownloadThreads){
			[thread cancel];
		}
	}
}



-(NSString *)filePathForFile{	
	NSArray *multiplePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *path = [[multiplePaths objectAtIndex:0] stringByAppendingPathComponent:@"Scores"];
	path = [path stringByExpandingTildeInPath];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if([fileManager contentsOfDirectoryAtPath:path error:NULL] == nil){
		//the directory doesn't exist
		[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	
	
	path = [path stringByAppendingPathComponent:[self sportName]];
	return path;
}

-(NSString *)sportName{
	if(teamType == AthleticsTeamMensBasketball){
		return @"NCAAM";
	}
	if(teamType == AthleticsTeamWomensBasketball){
		return @"NCAAW";
	}
	return @"NCAAF";
}

-(void)saveData:(NSArray *)data{
	
	BOOL success = [NSKeyedArchiver archiveRootObject:data toFile:[self filePathForFile]];
	//NSCoder *code = [[NSCoder alloc] init]
	
	if (success == NO) {
		NSLog(@"Writing to file failed.");
	}
}

-(NSArray *)loadData{
	NSString *path = [self filePathForFile];
	NSArray *gameData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	return gameData;
}

@end
