//
//  PhotoDataSource.m
//  iWVU
//
//  Created by Jared Crawford on 9/2/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "PhotoDataSource.h"
#import "PhotoFromData.h"

@implementation PhotoDataSource

@synthesize title, numberOfPhotos, maxPhotoIndex;

-(id)initWithTitle:(NSString *)sourceTitle andURL:(NSString *)sourceUrl{
	if (self = [super init]) {
		//start with an empty array to prevent null refrencing in the other functions
		self.title = sourceTitle;
		downloadingPhotoList = YES;
		NSThread *photoListDownloadThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadImageListFromURL:) object:sourceUrl];
		[photoListDownloadThread start];
		[photoListDownloadThread release];
		
		
		
	}
	return self;
}


- (BOOL)isLoading {
	return downloadingPhotoList;
}

- (BOOL)isLoaded {
	return !downloadingPhotoList;
}

 
- (NSInteger)numberOfPhotos {
	return [photoData count];
}

- (NSInteger)maxPhotoIndex {
	NSLog(@"Max Photo Index: %d", [photoData count]-1);
	return [photoData count]-1;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)photoIndex {
	if (photoIndex < [photoData count]) {
		return [photoData objectAtIndex:photoIndex];
	} else {
		return nil;
	}
}



- (void)thumbsViewController: (TTThumbsViewController*)controller didSelectPhoto: (id<TTPhoto>)photo{
	
}





-(void)downloadImageListFromURL:(NSString *)aURL{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSURL *url = [NSURL URLWithString:aURL];
	
	NSData *jsonData = [NSData dataWithContentsOfURL:url];
	[photoData release];
	NSError *err;
	NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&err];
	NSDictionary *query = [dict objectForKey:@"query"];
	NSDictionary *results = [query objectForKey:@"results"];
	NSDictionary *gallery = [results objectForKey:@"gallery"];
	NSDictionary *album = [gallery objectForKey:@"album"];
	self.title = [album objectForKey:@"description"];
	NSArray *photoDataDicts = [album objectForKey:@"img"];
	
	NSMutableArray *mutablePhotoData = [NSMutableArray arrayWithCapacity:photoDataDicts.count];
	for (int i = 0; i < photoDataDicts.count; ++i) {
		id<TTPhoto> photo = [[[PhotoFromData alloc] initWithDictionary:[photoDataDicts objectAtIndex:i]] autorelease];
		if ((NSNull*)photo != [NSNull null]) {
			photo.photoSource = self;
			photo.index = i;
			[mutablePhotoData addObject:photo];
		}
	}
	
	photoData = [[NSArray arrayWithArray:mutablePhotoData] retain];
	
	downloadingPhotoList = NO;
	[self didFinishLoad];
	[pool release];
}





@end
