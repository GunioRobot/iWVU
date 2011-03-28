//
//  DiningLocation.m
//  iWVU
//
//  Created by Jared Crawford on 7/8/09.
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

#import "DiningLocation.h"
#import "BuildingLocationController.h"
#import "SQLite.h"
#import "DiningMenuSelectionViewController.h"



@implementation DiningLocation

@synthesize locationName;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *query = [NSString stringWithFormat:@"SELECT * FROM \"Buildings\" WHERE \"name\" LIKE \"%@\"", locationName];
	[SQLite initialize];
	NSArray *sqlData = [SQLite query:query].rows;
	if ([sqlData count] > 0) {
		locationData = [[sqlData objectAtIndex:0] retain];
	}
}



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
	/*
	 Menu
	 
	 Website
	 
	 Adress
	 Location
	 
	 Phone Number
	 */
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
		if([[locationData objectForKey:@"menuID"] isEqualToString:@""]){
			return 0;
		}
		return 1;
	}
	else if(section == 1){
		//website
		return 1;
	}
	else if(section == 2){
		return 2;
	}
	else if(section == 3){
		if([@"" isEqualToString:[locationData objectForKey:@"phone"]]){
			return 0;
		}
		return 1;
	}
	
	return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	[AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.detailTextLabel.adjustsFontSizeToFitWidth = NO;
	cell.textLabel.adjustsFontSizeToFitWidth = NO;
    
    // Set up the cell...
	NSString *mainLabel = @"";
	NSString *detailLabel = @"";
	
	if(indexPath.section == 0){
		mainLabel = @"Daily Menu";
	}
	else if(indexPath.section == 1){
		//
		mainLabel = @"Website";
	}
	else if(indexPath.section == 2){
		
		if (indexPath.row == 0) {
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.numberOfLines = 2;
			NSString *address = [locationData objectForKey:@"physical_address"];
			mainLabel = [NSString stringWithFormat:@"%@\nMorgantown, WV 26506", address];
		}
		else{
			mainLabel = @"View on map";
		}
	}
	else if(indexPath.section == 3){
		mainLabel = @"Phone";
		detailLabel = [locationData objectForKey:@"Phone"];
	}
	
	
	
	
	cell.textLabel.text = mainLabel;
	cell.detailTextLabel.text = detailLabel;
	
	return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if ((indexPath.section == 2)&&(indexPath.row == 0)) {
		return (1.5 * tableView.rowHeight);
	}
	return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	
	if(indexPath.section == 0){
		DiningMenuSelectionViewController *viewController = [[DiningMenuSelectionViewController alloc] initWithDiningLocation:[locationData objectForKey:@"menuID"] andName:locationName];
		[self.navigationController pushViewController:viewController animated:YES];
	}
	else if(indexPath.section == 1){
		NSString *website = [locationData objectForKey:@"website"];
		if (![website isEqualToString:@""]) {
			website = [@"http://" stringByAppendingString:website];
		}
		else {
			website = @"http://diningservices.wvu.edu";
		}
		OPENURL(website);
	}
	else if(indexPath.section == 2){
		if(indexPath.row == 1){
			BuildingLocationController *theBuildingView = [[BuildingLocationController alloc] initWithNibName:@"BuildingLocation" bundle:nil];
			theBuildingView.buildingName = locationName;
			theBuildingView.navigationItem.title = locationName;
			[self.navigationController pushViewController:theBuildingView animated:YES];
			[theBuildingView release];
		}
	}
	else if(indexPath.section == 3){
		NSString *phoneNum = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
		[AppDelegate callPhoneNumber:phoneNum];
	}	
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if ([self tableView:self.tableView numberOfRowsInSection:section] >= 1) {
		if(section == 2){
			return @"Dining Location";
		}
	}
	return nil;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	//these are the default's, but I'm going to explicitly define them, just to be safe
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		return (UIInterfaceOrientationPortrait == interfaceOrientation);
	}
	return YES;
}



- (void)dealloc {
	[locationData release];
	self.locationName = nil;
	[super dealloc];
}





@end

