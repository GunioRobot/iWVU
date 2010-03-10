//
//  AthleticScoreData.h
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
#import <UIKit/UIKit.h>

@protocol AthleticScoreDataDelegate;

typedef enum {
	AthleticsTeamMensBasketball,
	AthleticsTeamWomensBasketball,
	AthleticsTeamFootball
} AthleticsTeam;

@interface AthleticScoreData : NSObject{

	NSArray *downloadedGameData;
	NSArray *homeLogos;
	NSArray *awayLogos;
	
	AthleticsTeam teamType;
	
	BOOL gameIsInProgress;
	int numOfImagesAwaitingDowload;
	NSDate *timeStamp;
	id<AthleticScoreDataDelegate> delegate;
	NSString *dataURL;
	
	NSMutableArray *tempHomeLogos;
	NSMutableArray *tempAwayLogos;
	
	NSMutableArray *imageDownloadThreads;
	NSThread *mainDataRequestThread;
	NSLock *removeThreadLock;
}

@property (nonatomic, assign) id<AthleticScoreDataDelegate> delegate;
@property (nonatomic, retain) NSString *dataURL;
@property (nonatomic, retain) NSArray *downloadedGameData;
@property (nonatomic, retain) NSArray *homeLogos;
@property (nonatomic, retain) NSArray *awayLogos;
@property (nonatomic) BOOL gameIsInProgress;
@property (nonatomic, retain) NSDate *timeStamp;

@property(nonatomic, retain) NSMutableArray *tempHomeLogos;
@property(nonatomic, retain) NSMutableArray *tempAwayLogos;
@property(nonatomic, retain) NSMutableArray *imageDownloadThreads;
@property(nonatomic, retain) NSThread *mainDataRequestThread;


-(id)initWithTeam:(AthleticsTeam)team;
-(void)requestScoreData;

//Local Score Caching methods
-(void)saveData:(NSArray *)data;
-(void)informDelegateOfNewData;
-(NSArray *)loadData;
-(NSString *)sportName;

 
-(void)finalizeImageArrays;
-(void)downloadGameImages:(NSNumber *)index;

-(NSString *)stringForKey:(NSString *)key inDict:(NSDictionary *)dict;
-(void)getImages;

-(void)cancelAllDownloads;

@end



@protocol AthleticScoreDataDelegate

//This message will be sent immediately with localy cached data
//Again after scores download
//and finally after logos download
-(void)newScoreDataAvailable;

@end


