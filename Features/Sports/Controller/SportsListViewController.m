//
//  SportsListViewController.m
//  iWVU
//
//  Created by Jared Crawford on 3/5/10.
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

#import "SportsListViewController.h"
#import "SQLite.h"
#import "TwitterBubbleViewController.h"
#import "CalendarViewController.h"
#import "SportViewController.h"
#import "AthleticScoresViewController.h"

@implementation SportsListViewController




- (void)viewDidLoad {
    [super viewDidLoad];
	[SQLite initialize];
	availableSports = [[SQLite query:@"SELECT * FROM \"Athletics\""].rows retain];
    
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
	//Calendar
	//Sports
	//MSNSportsNET
	//Twitter
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 1){
		return [availableSports count];
	}
	return 1;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.textLabel.text = @"";
	cell.detailTextLabel.text = @"";
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if(indexPath.section == 0){
		cell.textLabel.text = @"Athletic Calendar";
	}
	else if(indexPath.section == 1){
		cell.textLabel.text = [[availableSports objectAtIndex:indexPath.row] valueForKey:@"sport"];
	}
	else if(indexPath.section == 2){
		cell.textLabel.text = @"MSNSportsNET.com";
	}
	else if(indexPath.section == 3){
		cell.textLabel.text = @"Twitter";
		cell.detailTextLabel.text = @"@WVUSportsBuzz";
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if(indexPath.section == 0){
		NSString *urlKey = @"athletics";
		CalendarViewController *viewController = [[CalendarViewController alloc] init];
		viewController.calendarKey = urlKey;
		viewController.navigationItem.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
		[self.navigationController pushViewController:viewController animated:YES];
		[viewController release];
	}
	else if(indexPath.section == 1){
		//open the sport view
		NSDictionary *dict = [availableSports objectAtIndex:indexPath.row];
		SportViewController *viewController = [[SportViewController alloc] initWithSportData:dict];
		viewController.navigationItem.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
		[self.navigationController pushViewController:viewController animated:YES];
		[viewController release];
	}
	if(indexPath.section == 2){
		OPENURL(@"http://www.MSNSportsNET.com");
	}
	else if(indexPath.section == 3){
		NSString *userName = [[tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text substringFromIndex:1];
		TwitterBubbleViewController *viewController = [[TwitterBubbleViewController alloc] initWithUserName:userName];
		viewController.navigationItem.title = userName;
		[self.navigationController pushViewController:viewController animated:YES];
		[viewController release];
	}
	
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 1){
		return @"Sports";
	}
	return nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

