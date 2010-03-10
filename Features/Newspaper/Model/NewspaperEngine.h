//
//  NewspaperEngine.h
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

#import <Foundation/Foundation.h>

#define USER_DEFAULT_NEWSPAPER_CACHE_KEY @"cacheNewspaperContent"
#define USER_DEFAULT_NEWSPAPER_CACHE_AFFIMATIVE @"YES_I_WANT_TO_CACHE"
#define USER_DEFAULT_NEWSPAPER_CACHE_NEGATIVE @"NO_I_DONT_WANT_TO_CACHE"

@protocol NewspaperEngineDelegate;

@interface NewspaperEngine : NSObject {
	
	NSDate *currentDate;
	NSDate *requestedDate;
	id<NewspaperEngineDelegate> delegate;
	BOOL stillDownloading;
	NSMutableDictionary *numberOfPagesForDate;
	NSMutableArray *currentlyRunningThreads;

}

@property (nonatomic, assign) id<NewspaperEngineDelegate> delegate;
@property (nonatomic, retain) NSDate *currentDate;
@property (nonatomic, retain) NSDate *requestedDate;

-(id)initWithDelegate:(id)aDelegate;


-(void)downloadPagesForDate:(NSDate *)aDate;
-(BOOL)isStillDownloading;
-(void)cancelDownloads;


-(UIImage *)getPage:(int)pageNum forDate:(NSDate *)date;
-(int)numberOfPagesForDate:(NSDate *)date;

-(void)clearAllLocallyCachedPages;
-(NSMutableDictionary *)getNumberOfPagesDictionary;
-(void)storeNumberOfPagesDictionary;

@end







@protocol NewspaperEngineDelegate

-(void)newDataAvailable;

@end
