//
//  NewspaperEngine.h
//  iWVU
//
//  Created by Jared Crawford on 2/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NewspaperEngineDelegate;

@interface NewspaperEngine : NSObject {
	
	NSArray *downloadedPages;
	NSDate *currentDate;
	NSDate *requestedDate;
	id<NewspaperEngineDelegate> delegate;
	BOOL stillDownloading;

}

@property (nonatomic, assign) id<NewspaperEngineDelegate> delegate;
@property (nonatomic, retain) NSArray *downloadedPages;
@property (nonatomic, retain) NSDate *currentDate;
@property (nonatomic, retain) NSDate *requestedDate;

-(id)initWithDelegate:(id)aDelegate;
-(void)downloadPagesForDate:(NSDate *)aDate;
-(BOOL)isStillDownloading;

@end







@protocol NewspaperEngineDelegate

-(void)newDataAvailable;

@end
