//
//  BusesMain.m
//  iWVU
//
//  Created by Jared Crawford on 6/24/09.
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

#import "BusesMain.h"
#import "iWVUAppDelegate.h"
#import "RoutePlanner.h"


@implementation BusesMain


@synthesize section0Rows;
@synthesize section1Rows;
@synthesize section2Rows;
@synthesize section3Rows;

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
	
	section0Rows = [[NSArray alloc] initWithObjects:@"Live Locations", @"Late Status", nil];
	section1Rows = [[NSArray alloc] initWithObjects:@"Route Planner", nil];
	section2Rows = [[NSArray alloc] initWithObjects:@"Route Information and Maps", nil];
	section3Rows = [[NSArray alloc] initWithObjects:@"Mountain Line",@"BusRide.org", nil];
	
	
	
}
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case 0:
			return [section0Rows count];
			break;
		case 1:
			return [section1Rows count];
			break;
		case 2:
			return [section2Rows count];
			break;
		case 3:
			return [section3Rows count];
			break;
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
	
    // Set up the cell...
	
	NSString *mainText = @"";
	
	switch (indexPath.section) {
		case 0:
			mainText =  [section0Rows objectAtIndex:indexPath.row];
			break;
		case 1:
			mainText =  [section1Rows objectAtIndex:indexPath.row];
			break;
		case 2:
			mainText =  [section2Rows objectAtIndex:indexPath.row];
			break;
		case 3:
			mainText =  [section3Rows objectAtIndex:indexPath.row];
			if(indexPath.row == 0){
				cell.detailTextLabel.text = @"(304) 291-RIDE";
			}
			break;
	}
	
	cell.textLabel.text = mainText;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	[tableView deselectRowAtIndexPath:indexPath	animated:YES];
	
	iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	NSString *cellsLabel = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
	
	if([@"Live Locations" isEqualToString:cellsLabel]){
		UIAlertView *err = [[UIAlertView alloc] initWithTitle:nil message:@"\n\nComing soon..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
		[err show];
		[self performSelector:@selector(dismissErr:) withObject:err afterDelay:2];
	}
	else if([@"Route Planner" isEqualToString:cellsLabel]){
		RoutePlanner *theRouteView = [[RoutePlanner alloc] initWithNibName:@"RoutePlanner" bundle:nil];
		theRouteView.navigationItem.title = @"Bus Route Planner";
		UIBarButtonItem *backRouteButton = [[UIBarButtonItem alloc] initWithTitle:@"Route" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		theRouteView.navigationItem.backBarButtonItem = backRouteButton;
		[backRouteButton release];
		[AppDelegate.navigationController pushViewController:theRouteView animated:YES];
		[theRouteView release];
	}
	else if([@"Route Information and Maps" isEqualToString:cellsLabel]){
		[AppDelegate loadWebViewWithURL:@"http://busride.org/Routes.htm" andTitle:@"Routes & Maps"];
	}
	else if([@"Mountain Line" isEqualToString:cellsLabel]){
		[AppDelegate callPhoneNumber:@"(304) 291-7433"];
	}
	else if([@"BusRide.org" isEqualToString:cellsLabel]){
		[AppDelegate loadWebViewWithURL:@"http://www.busride.org" andTitle:@"BusRide.org"];
	}
	else if([@"Late Status" isEqualToString:cellsLabel]){
		[AppDelegate loadWebViewWithURL:@"http://www.busride.org/MyBus/MyBus.htm" andTitle:cellsLabel];
	}
}


-(void)dismissErr:(UIAlertView *)err{
	[err dismissWithClickedButtonIndex:0 animated:YES];
	[err release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	
	self.section0Rows = nil;
	self.section1Rows = nil;
	self.section2Rows = nil;
	self.section3Rows = nil;
	
	
    [super dealloc];
}





@end

