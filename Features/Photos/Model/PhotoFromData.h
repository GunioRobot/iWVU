//
//  PhotoFromData.h
//  iWVU
//
//  Created by Jared Crawford on 9/2/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

@interface PhotoFromData : NSObject <TTPhoto> {

	NSDictionary *photoData;
	
	//TTPhoto elements
	CGSize size;
	NSInteger index;
	id<TTPhotoSource> photoSource;
}

-(id)initWithDictionary:(NSDictionary *)newPhotoData;

@end
