    //
//  PhotoGridViewController.m
//  iWVU
//
//  Created by Jared Crawford on 10/8/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "PhotoGridViewController.h"
#import "FullScreenPhotoViewController.h"
#import "SQLite.h"


@implementation PhotoGridViewController

#define BASE_URL_FOR_PHOTO_ARCHIVES_PART_1 @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20xml%20where%20url%3D%27http%3A%2F%2Ffeaturearchive.wvu.edu%2Fr%2Fslideshow%2Fordered%2F"
#define BASE_URL_FOR_PHOTO_ARCHIVES_PART_2 @".xml%27%20limit%201&format=json"


- (void)viewDidLoad {
    
	[SQLite initialize];
	NSArray *urlKeys = [[SQLite query:@"SELECT * FROM \"Photos\""].rows retain];
	NSMutableArray *collectionURLsMutable = [NSMutableArray arrayWithCapacity:[urlKeys count]];
	for (NSDictionary *dict in urlKeys) {
		NSString *JSONURL = [NSString stringWithFormat:@"%@%@%@", BASE_URL_FOR_PHOTO_ARCHIVES_PART_1, [dict objectForKey:@"CollectionKey"], BASE_URL_FOR_PHOTO_ARCHIVES_PART_2];
		//NSLog(@"\n\n%@\n\n", [dict objectForKey:@"CollectionKey"]);
		[collectionURLsMutable addObject:JSONURL];
	}
	
	NSArray *collectionURLs = [NSArray arrayWithArray:collectionURLsMutable];
	
	
	
	thePhotoSource = [[PhotoDataSource alloc] initWithTitle:@"WVU Photos" andURLs:collectionURLs];
	
	self.photoSource = thePhotoSource;
	self.delegate = thePhotoSource;
	
	[super viewDidLoad];
	
	//For some reason, Three20 decided to make this view controller not follow the traditional
	//navigation controller paragigm. I will restore this functionality.
	self.navigationItem.rightBarButtonItem = nil;
	NSArray *viewControllersStack = self.navigationController.viewControllers;
	if ([viewControllersStack count] >= 2) {
		UIViewController *viewControllerBeforeThisOne = [viewControllersStack objectAtIndex:([viewControllersStack count] - 2)];
		self.navigationItem.leftBarButtonItem = viewControllerBeforeThisOne.navigationItem.backBarButtonItem;
	}
	
	
}



- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	/*
	if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)||(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
		FullScreenPhotoViewController *coverFlowView = [[FullScreenPhotoViewController alloc] initWithPhotoSource:thePhotoSource];
		coverFlowView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		[self presentModalViewController:coverFlowView animated:YES];
	}
	 */
}
	
	
	


- (void)dealloc {
	[thePhotoSource release];
    [super dealloc];
}


@end
