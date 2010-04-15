//
//  GANavigationControllerDelegate.m
//  iWVU
//
//  Created by Jared Crawford on 3/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GANavigationControllerDelegate.h"


@implementation GANavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
	NSError *anError;
	NSString *pageStackStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	int pageIndex = 0;
	//we don't want to get the RootViewController, so we're skipping the 0th element
	for(UIViewController *aViewController in navigationController.viewControllers){
		if(pageIndex > 0){
			pageStackStr = [pageStackStr stringByAppendingPathComponent:aViewController.navigationItem.title];
		}
		pageIndex++;
	}
	NSLog(@"%@",pageStackStr);
	pageStackStr = [pageStackStr stringByReplacingOccurrencesOfString:@"." withString:@"-"];
	GANTracker *aTracker = [GANTracker sharedTracker];
	[aTracker trackPageview:pageStackStr withError:&anError];
	if(anError){
		NSLog([anError description]);
	}
}




@end
