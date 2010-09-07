//
//  TwitterUserIconDB.h
//  iWVU
//
//  Created by Jared Crawford on 8/16/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TwitterUserIconDBDelegate;


@interface TwitterUserIconDB : NSObject {

	id<TwitterUserIconDBDelegate> delegate;
	
	NSOperationQueue *imageOperationQueue;
	
    NSLock *userImagesLock;
	NSMutableDictionary *userImages;
	
	NSLock *userImageURLsLock;
	NSMutableDictionary *userImageURLs;
	
	NSLock *archivingLock;
	
}

@property (nonatomic, assign) id<TwitterUserIconDBDelegate> delegate;

-(id)initWithIconDelegate:(id<TwitterUserIconDBDelegate>)aDelegate;
-(UIImage *)userIconWithUserData:(NSDictionary *)userData;
-(UIImage *)defaultImage;

@end


@protocol TwitterUserIconDBDelegate

-(void)twitterUserIconDBUpdated;

@end