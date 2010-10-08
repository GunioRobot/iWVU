//
//  MainScreenLauncherView.m
//  iWVU
//
//  Created by Jared Crawford on 1/2/10.
//  Copyright 2009 Jared Crawford. All rights reserved.
//

/*
 Copyright (c) 2009 Jared Crawford
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 The trademarks owned or managed by the West Virginia 
 University Board of Governors (WVU) are used under agreement 
 between the above copyright holder(s) and WVU. The West 
 Virginia University Board of Governors maintains ownership of all 
 trademarks. Reuse of this software or software source code, in any 
 form, must remove all references to any trademark owned or 
 managed by West Virginia University.
 */

#import "MainScreenLauncherView.h"
#import "iWVUAppDelegate.h"
#import "MainScreen.h"


@implementation MainScreenLauncherView

- (CGFloat)rowHeight {
    

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		//for the iPhone it's easy
		return 120;
	}
	
	
	
	//for the iPad, it varies by orientation
	//and to get the orientation we need an active UIViewController
	//so we'll get the rootViewController
	iWVUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	MainScreen *mainScreen = [appDelegate.navigationController.viewControllers objectAtIndex:0];
	if((mainScreen.interfaceOrientation == UIDeviceOrientationLandscapeLeft)||(mainScreen.interfaceOrientation == UIDeviceOrientationLandscapeRight)){
		//for iPad Landscape
		return 165;
	}
	
	
	//for iPad portrait
	return 185;
}



-(void)layoutSubviews{
	[super layoutSubviews];
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		self.columnCount = 3;
	}
	else {
		BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
		if (isLandscape) {
			self.columnCount = 5;
		}
		else {
			self.columnCount = 4;
		}
	}
}



-(NSArray *)defaultFeatures{
	return  [NSArray arrayWithObjects:
			 @"Athletics",
			 @"Calendar",
			 @"Directory",
			 @"Newspaper",
			 @"Twitter",
			 @"Map",
			 @"PRT",
			 @"Buses",
			 @"Libraries",
			 @"Dining",
			 @"Photos",
			 @"Radio",
			 @"Emergency",
			 @"WVU Mobile",
			 @"WVU Today",
			 @"WVU Alert",
			 @"eCampus",
			 @"MIX",
			 @"WVU.edu",
			 @"Settings",
			 nil];
}


-(void)verifyLayoutIsNotCorrupted{
	int numberOfIcons = 0;
	for (NSArray *page in self.pages) {
		numberOfIcons += [page count];
	}
	
	if (numberOfIcons != [[self defaultFeatures] count]) {
		UIAlertView *err = [[UIAlertView alloc] initWithTitle:nil message:@"Your icon configuration has become corrupted. The default configuration will be reset." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
		[err show];
		[err release];
		[self resetMainScreenPositions];
	}
	
}
	
	

-(NSString *)filePathForMainScreenPosition{	
	NSArray *multiplePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [[multiplePaths objectAtIndex:0] stringByAppendingPathComponent:@"mainScreenPages"];
	return path;
}

-(void)resetMainScreenPositions{
	NSString *aPath = [self filePathForMainScreenPosition];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *err;
	[fileManager removeItemAtPath:aPath error:&err];
	[self createDefaultView];
	
}

-(void)saveMainScreenPosition{
	[self verifyLayoutIsNotCorrupted];
	[NSKeyedArchiver archiveRootObject:self.pages toFile:[self filePathForMainScreenPosition]];
}

-(NSArray *)loadMainScreenPosition{
	return [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathForMainScreenPosition]];
}






-(void)createDefaultView{
	
	NSArray *defaultFeatures = [self defaultFeatures];
	NSMutableArray *pageItems = [NSMutableArray array];
	NSMutableArray *pageList = [NSMutableArray array];
	int itemsInPage = 9;
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		itemsInPage = 20;
	}
	int i = 0;
	
	
	for (NSString *feature in defaultFeatures) {
		if ((i%itemsInPage == 0)&&(i!=0)) {
			[pageList addObject:[NSArray arrayWithArray:pageItems]];
			pageItems = [NSMutableArray array];
		}
		
		NSString *escapedString = [feature stringByReplacingOccurrencesOfString:@" " withString:@"_"];
		escapedString = [escapedString stringByReplacingOccurrencesOfString:@"." withString:@"_"];
		
		
		NSString *imageURL = [NSString stringWithFormat:@"bundle://Main_%@.png",escapedString];
		
		NSString *selectorURL = [NSString stringWithFormat:@"bundle://mainScreen/%@", feature];
		
		TTLauncherItem *item = [[[TTLauncherItem alloc] initWithTitle:feature
																image:imageURL
																  URL:selectorURL canDelete:NO] autorelease];
		
		item.style = @"mainScreenLauncherButton:";
		[pageItems addObject:item];
		i++;
		
	}
	[pageList addObject:[NSArray arrayWithArray:pageItems]];
	self.pages = [NSArray arrayWithArray:pageList];	
	[self saveMainScreenPosition];
}




@end
