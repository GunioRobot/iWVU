//
//  PhotoDataSource.m
//  iWVU
//
//  Created by Jared Crawford on 9/2/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "PhotoDataSource.h"
#import "PhotoFromData.h"

#define TEMP_URL @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20xml%20where%20url%3D%27http%3A%2F%2Fphotoarchive.sitespace.wvu.edu%2Fr%2Fslideshow%2Fordered%2F3628.xml%27%20limit%201&format=json"

@implementation PhotoDataSource

@synthesize title, numberOfPhotos, maxPhotoIndex;

-(id)initWithTitle:(NSString *)sourceTitle andURL:(NSString *)sourceUrl{
	if (self = [super init]) {
		//start with an empty array to prevent null refrencing in the other functions
		photoData = [[NSArray array] retain];
		self.title = sourceTitle;
		
		NSURL *url = [NSURL URLWithString:TEMP_URL];
		// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		// !!! THIS SHOULD BE THREADED !!!
		// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		
		NSData *jsonData = [NSData dataWithContentsOfURL:url];
		[photoData release];
		NSError *err;
		NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&err];
		NSDictionary *query = [dict objectForKey:@"query"];
		NSDictionary *results = [query objectForKey:@"results"];
		NSDictionary *gallery = [results objectForKey:@"gallery"];
		NSDictionary *album = [gallery objectForKey:@"album"];
		self.title = [album objectForKey:@"description"];
		photoData = [album objectForKey:@"img"];
		[photoData retain];
		
		
	}
	return self;
}


- (NSInteger)numberOfPhotos {
	return [photoData count];
}

- (NSInteger)maxPhotoIndex {
	return [photoData count]-1;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)photoIndex {
	if (photoIndex < [photoData count]) {
		return [[[PhotoFromData alloc] initWithDictionary:[photoData objectAtIndex:photoIndex]] autorelease];
	} else {
		return nil;
	}
}



- (void)thumbsViewController: (TTThumbsViewController*)controller didSelectPhoto: (id<TTPhoto>)photo{
	
}

@end
