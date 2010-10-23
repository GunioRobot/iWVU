//
//  PhotoDataSource.h
//  iWVU
//
//  Created by Jared Crawford on 9/2/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "CJSONDeserializer.h"





@interface PhotoDataSource : TTURLRequestModel <TTPhotoSource, TTThumbsViewControllerDelegate> {
	NSArray *photoData;
	NSString *title;
	int photoListsDownloaded;
	int photoListsRequested;
	NSLock *photoDataLock;
	
}

-(id)initWithTitle:(NSString *)sourceTitle andURL:(NSString *)sourceUrl;
-(id)initWithTitle:(NSString *)sourceTitle andURLs:(NSArray *)sourceUrls;

@end
