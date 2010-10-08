//
//  PhotoFromData.m
//  iWVU
//
//  Created by Jared Crawford on 9/2/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "PhotoFromData.h"
#import "NSString+MD5.h"


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

-(void)setCaption:(NSString *)text{
	//not implemented
}

-(NSString *)caption{
	//NSLog(@"\n\n%@\n\n", [[photoData objectForKey:CAPTION] stringByDecodingXMLEntities]);
	NSString *fullHTML = [[photoData objectForKey:CAPTION] stringByDecodingXMLEntities];
	NSString *meaningfullText = [[fullHTML stringFro
	
	
	return ;
}

@end
