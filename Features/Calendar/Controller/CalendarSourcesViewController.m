//
//  CalendarSourcesViewController.m
//  iWVU
//
//  Created by Jared Crawford on 3/4/10.
//  Copyright Jared Crawford 2010. All rights reserved.
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

#import "CalendarSourcesViewController.h"
#import "SQLite.h"
#import "CalendarViewController.h"



@implementation CalendarSourcesViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	[SQLite initialize];
	generalCalendars = [[SQLite query:@"SELECT * FROM \"Calendars\" WHERE \"category\" LIKE \"General\""].rows retain];
	athleticCalendars = [[SQLite query:@"SELECT * FROM \"Calendars\" WHERE \"category\" LIKE \"Athletics\""].rows retain];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 0){
		return @"WVU Calendar";
	}
	else if(section == 1){
		return @"General Calendars";
	}
	else if(section == 2){
		return @"Athletic Calendars";
	}
	return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	if(section == 0){
		return [NSString stringWithFormat:@"A maximum of %d events\nwill be downloaded.", MAX_NUMBER_OF_CALENDAR_ITEMS];
	}
	return nil;
}
	

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 1){
		return [generalCalendars count];
	}
	if(section == 2){
		return [athleticCalendars count];
	}
	return 1;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.textLabel.text = @"All";
	
	if(indexPath.section == 1){
		cell.textLabel.text = [[generalCalendars objectAtIndex:indexPath.row] valueForKey:@"name"];
	}
	else if(indexPath.section == 2){
		cell.textLabel.text = [[athleticCalendars objectAtIndex:indexPath.row] valueForKey:@"name"];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString *urlKey = @"all";
	NSString *navTitle = @"All Calendars";
	
	
	
	if(indexPath.section == 1){
		urlKey = [[generalCalendars objectAtIndex:indexPath.row] valueForKey:@"url"];
		navTitle = [[generalCalendars objectAtIndex:indexPath.row] valueForKey:@"name"];
	}
	else if(indexPath.section == 2){
		urlKey = [[athleticCalendars objectAtIndex:indexPath.row] valueForKey:@"url"];
		navTitle = [[athleticCalendars objectAtIndex:indexPath.row] valueForKey:@"name"];
	}
	
	CalendarViewController *viewController = [[CalendarViewController alloc] init];
	viewController.calendarKey = urlKey;
	viewController.navigationItem.title = navTitle;
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	//these are the default's, but I'm going to explicitly define them, just to be safe
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		return NO;
	}
	return YES;
}



- (void)dealloc {
    [generalCalendars release];
	generalCalendars = nil;
	[athleticCalendars release];
	athleticCalendars = nil;
	[super dealloc];
}


@end

