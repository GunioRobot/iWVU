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

#define DATA_FILE_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"RecentScoreData"]

@implementation AthleticScoreData

@synthesize downloadedGameData;
@synthesize numberOfCompletedGames;
@synthesize numberOfUpcomingGames;
@synthesize totalNumberOfGames;
@synthesize gameIsInProgress;
@synthesize delegate;
@synthesize timeStamp;

-(id)init{
	[super init];
	haveDownloadedTheData = NO;
	self.downloadedGameData = [NSArray array];
	gameIsInProgress = NO;
	numberOfCompletedGames = 0;
	numberOfUpcomingGames = 0;
	totalNumberOfGames = 0;
	numOfImagesAwaitingDowload = 0;
	return self;
}

-(id)initWithURLstr:(NSString *)aURL{
	if (self = [super init]) {
		XMLURL = [aURL retain];
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


-(void)getImageForURL:(NSString *)urlStr inDictionary:(NSMutableDictionary *)dict{
	NSArray *dataArray = [[NSArray alloc] initWithObjects:urlStr, dict, nil];
	NSThread *aThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadAnImage:) object:dataArray];
	[aThread start];
	[aThread release];
}

-(void)downloadAnImage:(NSArray *)dataArray{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *urlStr = [dataArray objectAtIndex:0];
	NSMutableDictionary *dict = [dataArray objectAtIndex:1];
	
	NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
	UIImage *img = [UIImage imageWithData:imgData];
	[dict setValue:img forKey:@"opponentLogoUIImage"];
	numOfImagesAwaitingDowload--;
	[pool release];
}



-(void)requestScoreData{
	//immediately return data
	self.downloadedGameData = [self loadData];
	[self informDelegateOfNewData];
	
	
	//get the right URL for the sport
	NSString *requestURLstr = @"http://jaredcrawford.org/iWVUSampleData/MensBasketball.xml";
	if (XMLURL) {
		requestURLstr = XMLURL;
	}
	
	NSThread *aRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(startTheParserWithURL:) object:[NSURL URLWithString:requestURLstr]];
	[aRequestThread start];
	[aRequestThread release];
	
	
	
}

-(void)startTheParserWithURL:(NSURL *)aURL{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:aURL];
	[xmlParser setDelegate:self];
	[xmlParser parse];
	[xmlParser release];
	[pool release];
	 
}

-(void)informDelegateOfNewData{
	if ([((NSObject *)delegate) respondsToSelector:@selector(newScoreDataAvailable)]) {
		[delegate newScoreDataAvailable];
	}
}


//Parser Functions


- (void)parserDidStartDocument:(NSXMLParser *)parser{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	gameDictionaries = [[NSMutableArray array] retain];
	tempNumGames = 0;
	tempGameInProgress = NO;
	tempNumCompleted = 0;
	tempNumUpcoming = 0;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
	NSLog(@"images downloading:%d", numOfImagesAwaitingDowload);
	while (numOfImagesAwaitingDowload > 0) {
		//wait for the images to Download on other threads
	}
	self.timeStamp = [NSDate date];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	haveDownloadedTheData = YES;
	NSLog(@"Finished parsing XML");
	self.downloadedGameData = [NSArray arrayWithArray:gameDictionaries];
	self.numberOfCompletedGames = tempNumCompleted;
	self.numberOfUpcomingGames = tempNumUpcoming;
	self.totalNumberOfGames = tempNumGames;
	self.gameIsInProgress = tempGameInProgress;
	[self saveData:gameDictionaries];
	gameDictionaries = nil;
	[self performSelectorOnMainThread:@selector(informDelegateOfNewData) withObject:nil waitUntilDone:NO];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict{
	if ([elementName isEqualToString:@"game"]) {
		currentGameDict = [[NSMutableDictionary dictionary] retain];
	}
	else {
		currentElementName = [elementName retain];
		currentElementText = [@"" retain];
	}

}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	NSString *tempStr = [[currentElementText stringByAppendingString:string] retain];
	[currentElementText release];
	currentElementText = tempStr;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	if ([elementName isEqualToString:@"game"]) {
		//download the opponent logo
		NSString *opponentLogoURL = [currentGameDict objectForKey:@"opponentLogo"];
		if (opponentLogoURL!=nil ) {
			[self getImageForURL:opponentLogoURL inDictionary:currentGameDict];
			numOfImagesAwaitingDowload++;
		}
		
		//add the game to the array
		[gameDictionaries addObject:currentGameDict];
		
		//increment The Correct Counts
		tempNumGames++;
		int hasStarted = [[self stringForKey:@"hasStarted" inDict:currentGameDict] intValue];
		int hasFinished = [[self stringForKey:@"hasFinished" inDict:currentGameDict] intValue];
		
		if ((hasStarted!=0) && (hasFinished == 0)) {
			tempGameInProgress = YES;
		}
		else if (hasFinished!=0) {
			tempNumCompleted++;
		}
		else if (hasStarted!=0) {
			tempNumUpcoming++;
		}
		
		//release dict
		[currentGameDict release];
		currentGameDict = nil;
		
	}
	else if([elementName isEqualToString:@"doc"]){
		//this is the top wrapper, ignore it
	}
	else {
		[currentGameDict setValue:currentElementText forKey:currentElementName];
		[currentElementText release];
		[currentElementName release];
		currentElementName = nil;
		currentElementText = nil;
	}
}


-(NSString *)filePathForFile{	
	NSArray *multiplePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [[multiplePaths objectAtIndex:0] stringByAppendingPathComponent:[delegate sportName]];
	return path;
}

-(void)saveData:(NSArray *)data{
	
	BOOL success = [NSKeyedArchiver archiveRootObject:data toFile:[self filePathForFile]];
	//NSCoder *code = [[NSCoder alloc] init]
	
	if (success == NO) {
		NSLog(@"Writing to file failed.");
	}
}

-(NSArray *)loadData{
	return [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathForFile]];
}

@end
