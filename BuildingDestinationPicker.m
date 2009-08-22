//
//  BuildingDestinationPicker.m
//  iWVU
//
//  Created by Jared Crawford on 6/25/09.
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

#import "BuildingDestinationPicker.h"
#import "iWVUAppDelegate.h"


@implementation BuildingDestinationPicker

@synthesize isStartingOrEnding;
@synthesize delegate;
@synthesize selectedIndexPath;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	NSMutableArray *buildings = [NSMutableArray array];
	
	NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"BuildingsLat.plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	
	for(NSString *building in dict){
		[buildings addObject:building];
	}
	buildingList=[[buildings sortedArrayUsingSelector:@selector(compare:)] retain];
	self.selectedIndexPath = [NSIndexPath indexPathForRow:999 inSection:0];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [buildingList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
    // Set up the cell...
	cell.textLabel.text = (NSString *)[buildingList objectAtIndex:indexPath.row];
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	if(indexPath.row == selectedIndexPath.row){
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	NSString *BuildingName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
	
	if(selectedIndexPath != nil){
		[tableView cellForRowAtIndexPath:selectedIndexPath].accessoryType = UITableViewCellAccessoryNone;
	}
	[self.delegate setBuilding:BuildingName forStartOrEnd:isStartingOrEnding];
	self.selectedIndexPath = indexPath;
	[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}





- (void)dealloc {
	self.selectedIndexPath = nil;
	self.isStartingOrEnding = nil;
	[buildingList release];
    [super dealloc];
}


@end

