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



-(id)initWithURLs:(NSArray *)sourceUrls{
	if (self = [super init]) {
		//allow large files to be downloaded
		[[TTURLRequestQueue mainQueue] setMaxContentLength:0];
		
		//start with an empty array to prevent null refrencing in the other functions
		photoData = [[NSArray array] retain];
		photoDataLock = [[NSLock alloc] init];
		photoListsRequested = [sourceUrls count];
		photoListsDownloaded = 0;
		
		for (int i=0; i<[sourceUrls count]; i++) {
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			NSThread *photoListDownloadThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadImageListFromURL:) object:[sourceUrls objectAtIndex:i]];
			[photoListDownloadThread start];
			[photoListDownloadThread release];
		}
		
	}
	return self;
}



-(id)initWithURL:(NSString *)sourceUrl{
	NSArray *urls = nil;
	if (sourceUrl) {
		urls = [NSArray arrayWithObject:sourceUrl];
	}
	self = [self initWithURLs:urls];
	return self;
}



-(id)initWithTitle:(NSString *)sourceTitle andURL:(NSString *)sourceUrl{
	if (self = [self initWithURL:sourceUrl]) {
		self.title = sourceTitle;
	}
	return self;
}


-(id)initWithTitle:(NSString *)sourceTitle andURLs:(NSArray *)sourceUrls{
	if (self = [self initWithURLs:sourceUrls]) {
		self.title = sourceTitle;
	}
	return self;
}


- (BOOL)isLoading {
	if (photoListsRequested == photoListsDownloaded) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
	
	if (photoListsDownloaded >= 1) {
		return NO;
	}
	return YES;
}

- (BOOL)isLoaded {
	if (photoListsDownloaded >= 1) {
		return YES;
	}
	return NO;
}

 
- (NSInteger)numberOfPhotos {
	return [photoData count];
}

- (NSInteger)maxPhotoIndex {
	//NSLog(@"Max Photo Index: %d", [photoData count]-1);
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
	NSLog(@"%@", aURL);
	
	NSURL *url = [NSURL URLWithString:aURL];
	NSData *jsonData = [NSData dataWithContentsOfURL:url];
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
			[mutablePhotoData addObject:photo];
		}
	}
	
	
	//An NSLock is needed here to prevent corruption of the NSArray
	[mutablePhotoData retain];
	[photoDataLock lock];
	NSArray *oldPhotoData = photoData;
	NSArray *unsortedNewData = [photoData arrayByAddingObjectsFromArray:mutablePhotoData];
	photoData = [unsortedNewData retain];
	//photoData = [[unsortedNewData sortedArrayUsingSelector:@selector(compare:)] retain];
	[oldPhotoData release];
	[mutablePhotoData release];
	photoListsDownloaded++;
	for (int i = 0; i < [photoData count]; i++) {
		id<TTPhoto> aPhoto = [photoData objectAtIndex:i];
		aPhoto.index = i;
	}
	if (photoListsDownloaded == photoListsRequested) {
		[self didFinishLoad];
	}
	[photoDataLock unlock];
	
	
	[pool release];
}

-(void)dealloc{
	[photoData release];
	[photoDataLock release];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[super dealloc];
}



@end
