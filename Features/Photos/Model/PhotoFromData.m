//
//  PhotoFromData.m
//  iWVU
//
//  Created by Jared Crawford on 9/2/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "PhotoFromData.h"


#define LARGE_SIZE @"orig"
#define MEDIUM_SIZE @"src"
#define SMALL_SIZE @"src"
#define THUMBNAIL_SIZE @"tn"
#define CAPTION @"caption"

@implementation PhotoFromData

@synthesize size, index, photoSource;

-(id)initWithDictionary:(NSDictionary *)newPhotoData{
	if (self = [super init]) {
		photoData = [newPhotoData retain];
	}
	return self;
}


- (NSString*)URLForVersion:(TTPhotoVersion)version {
	if (version == TTPhotoVersionLarge) {
		return [photoData objectForKey:LARGE_SIZE];
	} else if (version == TTPhotoVersionMedium) {
		return [photoData objectForKey:MEDIUM_SIZE];
	} else if (version == TTPhotoVersionSmall) {
		return [photoData objectForKey:SMALL_SIZE];
	} else if (version == TTPhotoVersionThumbnail) {
		return [photoData objectForKey:THUMBNAIL_SIZE];
	} else {
		return nil;
	}
}


-(NSString *)caption{
	return [photoData objectForKey:CAPTION];
}

@end
