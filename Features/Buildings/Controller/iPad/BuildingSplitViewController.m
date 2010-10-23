//
//  BuildingSplitViewController.m
//  iWVU
//
//  Created by Jared Crawford on 9/29/09.
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

#import "BuildingSplitViewController.h"


@implementation BuildingSplitViewController

-(id)init{
	if (self = [super init]) {
		listViewController = [[BuildingList alloc] initWithDelegate:self];
		listViewController.navigationItem.title = @"Building List";
		listViewController.delegate = self;
		locationViewController = [[BuildingLocationController alloc] initWithNibName:@"BuildingLocation" bundle:nil];
		NSString *buildingName = @"Mountainlair";
		locationViewController.buildingName = buildingName;
		self.navigationItem.title = buildingName;
		self.viewControllers = [NSArray arrayWithObjects:listViewController, locationViewController, nil];
		self.delegate = self;
	}
	return self;
}



-(void)viewDidLoad{
	[super viewDidLoad];
}


-(void)BuildingList:(BuildingList *)aBuildingList didFinishWithSelectionType:(BuildingSelectionType)type{
	if (locationViewController) {
		if (type == BuildingSelectionTypeBuilding) {
			NSString *buildingName = [aBuildingList selectedBuildingName];
			locationViewController.buildingName = buildingName;
			self.navigationItem.title = buildingName;
		}
		else if(type == BuildingSelectionTypeAllBuildings){
			NSString *buildingName = @"WVU Buildings";
			locationViewController.buildingName = @"All Buildings";
			self.navigationItem.title = buildingName;
		}
		[locationViewController reloadBuildingPins];
	}
}

-(BOOL)allowsCurrentLocation{
	return NO;
}

-(BOOL)allowsAllBuildings{
	return YES;
}



// Called when a button should be added to a toolbar for a hidden view controller.
- (void)splitViewController:(MGSplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc{
	barButtonItem.title = @"Buildings";
	self.navigationItem.rightBarButtonItem = barButtonItem;
}

// Called when the master view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(MGSplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
	if (self.navigationItem.rightBarButtonItem == barButtonItem) {
		self.navigationItem.rightBarButtonItem = nil;
	}
}





-(void)dealloc{
	[locationViewController release];
	[listViewController release];
	[super dealloc];
}


@end
