//
//  RadioDetails.h
//  iWVU
//
//  Created by Jared Crawford on 6/26/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NO_U92_ERROR_STR @"No internet connection"

@interface RadioDetails : NSObject {

	NSString *websiteStr;
	NSThread *backgroundThread;
	
	NSString *currentShow;
}

//This was designed to be used with key value observing
//
@property (nonatomic) NSString *currentShow;

-(void)refresh;

@end
