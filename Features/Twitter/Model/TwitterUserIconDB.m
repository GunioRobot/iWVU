//
//  TwitterUserIconDB.m
//  iWVU
//
//  Created by Jared Crawford on 8/16/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "TwitterUserIconDB.h"
#import "UIImage-NSCoding.h"

@implementation TwitterUserIconDB

@synthesize delegate;


-(NSString *)folderPath{
	NSArray *multiplePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [[multiplePaths objectAtIndex:0] stringByAppendingPathComponent:@"Twitter"];
	path = [path stringByExpandingTildeInPath];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if([fileManager contentsOfDirectoryAtPath:path error:NULL] == nil){
		//the directory doesn't exist
		[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	return path;
}


-(NSString *)filePathForImagesDictionary{	
	NSString *path = [self folderPath];
	path = [path stringByAppendingPathComponent:@"userImages"];
	return path;
}


-(NSString *)filePathForImageURLsDictionary{	
	NSString *path = [self folderPath];
	path = [path stringByAppendingPathComponent:@"userImageURLs"];
	return path;
}


-(void)archiveData{
	[archivingLock lock];
	BOOL success = [NSKeyedArchiver archiveRootObject:userImages toFile:[self filePathForImagesDictionary]];
	if (success == NO) {
		NSLog(@"Writing twitter user images to file failed.");
	}
	
	success = [NSKeyedArchiver archiveRootObject:userImageURLs toFile:[self filePathForImageURLsDictionary]];
	if (success == NO) {
		NSLog(@"Writing twitter user image URLs to file failed.");
	}

	[archivingLock unlock];
}

-(void)loadArchivedData{
	[archivingLock lock];
	userImages = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathForImagesDictionary]];
	if(!userImages){
		NSLog(@"Loading twitter user images from file failed.");
		userImages = [[NSMutableDictionary alloc] init];
	}
	else {
		[userImages retain];
	}
	
	userImageURLs = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathForImageURLsDictionary]];
	if(!userImageURLs){
		NSLog(@"Loading twitter user image URLs from file failed.");
		userImageURLs = [[NSMutableDictionary alloc] init];
	}
	else {
		[userImageURLs retain];
	}
	
	[archivingLock unlock];
}


-(id)initWithDelegate:(id<TwitterUserIconDBDelegate>)aDelegate{
	if (self = [super init]) {
		self.delegate = aDelegate;
		imageOperationQueue = [[NSOperationQueue alloc] init];
		userImagesLock = [[NSLock alloc] init];
		userImageURLsLock = [[NSLock alloc] init];
		archivingLock = [[NSLock alloc] init];
		[self loadArchivedData];
	}
	return self;
}




-(UIImage *)userIconWithUserData:(NSDictionary *)userData{
	NSString *screenName = [userData objectForKey:@"screen_name"];
	NSString *imageURL = [userData objectForKey:@"profile_image_url"];
	UIImage *userImage = nil;
	//the first thing we need to do is to see if we have an image for this URL already stored
	[userImageURLsLock lock];
	NSString *storedURL = [userImageURLs objectForKey:screenName];
	[userImageURLsLock unlock];
	if (![storedURL isEqualToString:imageURL]) {
		//before we get too far, we should set the default values
		//this will prevent multiple simultaneous downloads of the same user
		[userImageURLsLock lock];
		[userImageURLs setObject:imageURL forKey:[userData objectForKey:@"screen_name"]];
		[userImageURLsLock unlock];
		[userImagesLock lock];
		[userImages setObject:[self defaultImage] forKey:[userData objectForKey:@"screen_name"]];
		[userImagesLock unlock];
		//now we allocate an invocation operation to download the image
		NSInvocationOperation *downloadImageOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadUserImage:) object:userData];
		[imageOperationQueue addOperation:downloadImageOperation];
		[downloadImageOperation release];
		userImage = [self defaultImage];
	}
	//at this point, we either know that we have the right image based on the url
	//or we have set the default image and are now downloading the url
	[userImagesLock lock];
	userImage = [userImages objectForKey:screenName];
	[userImagesLock unlock];
	return userImage;
}



-(void)downloadUserImage:(NSDictionary *)userData{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"Requested Download of icon for:%@", [userData objectForKey:@"screen_name"]);
    NSString *imageURL = [userData objectForKey:@"profile_image_url"];
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
	UIImage *tempUserImage = [UIImage imageWithData:imgData];
	//because only iOS 4 implements [NSOperationQueue currentQueue], well check that first. It would be a bug to proceed
    //if the current queue is canceled, but short of a major rewrite, there's no workaround I've found yet
    if ((![[NSOperationQueue class] respondsToSelector:@selector(currentQueue)]) || (![[NSOperationQueue currentQueue] isSuspended])) {
		if (tempUserImage) {
			[userImagesLock lock];
            [userImages setObject:tempUserImage forKey:[userData objectForKey:@"screen_name"]];
            [userImagesLock unlock];
			[self archiveData];
            [(id)delegate performSelectorOnMainThread:@selector(twitterUserIconDBUpdated) withObject:nil waitUntilDone:NO];
		}
		else {
			//the user doesn't have an image, so we'll stick to the default
		}
	}
	[pool release];
}


-(UIImage *)defaultImage{
	return [UIImage imageNamed:@"FlyingWVSmall.png"];
}

- (void)dealloc {
    [imageOperationQueue cancelAllOperations];
	[imageOperationQueue setSuspended:YES];
    [imageOperationQueue release];
	[userImages release];
    [userImagesLock release];
	[userImageURLs release];
    [userImageURLsLock release];
    [super dealloc];
}

@end
