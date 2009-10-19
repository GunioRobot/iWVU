//
//  FootballSchedule.m
//  iWVU
//
//  Created by Jared Crawford on 6/10/09.
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

#import "FootballSchedule.h"
#import "iWVUAppDelegate.h"
#import "BuildingLocationController.h"
#import "TwitterBubbleViewController.h"


@implementation FootballSchedule

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
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
		return 5;
	}
	else if(section == 1){
		return 14;
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	iWVUAppDelegate *AppDelegate = [[UIApplication sharedApplication] delegate];
	cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
	NSString *mainText;
	NSString *subText = @"";
	cell.detailTextLabel.textColor = [UIColor blackColor];
	
    // Set up the cell...
	if(indexPath.section == 0){
		//
		cell = [tableView dequeueReusableCellWithIdentifier:@"Value1"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Value1"] autorelease];
		}
		cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
		
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		if(indexPath.row == 0){
			mainText = @"Team Website";
			subText = @"";
		}
		else if(indexPath.row == 1){
			//Roster
			mainText = @"Team Roster";
			subText = @"";
			
		}
		else if(indexPath.row == 2){
			//Twitter
			mainText = @"Student Tickets";
			subText = @"";
		}
		else if(indexPath.row == 3){
			//Twitter
			mainText = @"Bill Stewart's Twitter";
			subText = @"";
		}
		else if(indexPath.row == 4){
			mainText = @"Stadium Location";
			subText = @"";
		}
	}
	if(indexPath.section == 1){
		switch (indexPath.row) {
			case 0:
				mainText = @"Liberty";
				subText = @"Saturday Sep. 5, 2009";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 1:
				mainText = @"East Carolina";
				subText = @"Saturday Sep. 12, 2009";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 2:
				mainText = @"@Auburn";
				subText = @"Saturday Sep. 19, 2009";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 3:
				mainText = @"Bye";
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				break;
			case 4:
				mainText = @"Colorado";
				subText = @"Thursday Oct. 1, 2009";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 5:
				mainText = @"@Syracuse";
				subText = @"Saturday Oct. 10, 2009";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 6:
				mainText = @"Marshall";
				subText = @"Saturday Oct. 17, 2009";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 7:
				mainText = @"Connecticut";
				subText = @"Saturday Oct. 24, 2009";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 8:
				mainText = @"@USF";
				subText = @"Friday Oct. 30, 2009";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 9:
				mainText = @"Louisville";
				subText = @"Saturday Nov. 7, 2009";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 10:
				mainText = @"@Cincinnati";
				subText = @"Friday Nov. 13, 2009";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 11:
				mainText = @"Bye";
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				break;
			case 12:
				mainText = @"Pittsburgh";
				subText = @"Friday Nov. 27, 2009";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 13:
				mainText = @"@Rutgers";
				subText = @"Saturday Dec. 5, 2009";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			default:
				break;
		}
	}
	
	cell.textLabel.text = mainText;
	cell.detailTextLabel.text = subText;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	
	if(indexPath.section == 0){
		if(indexPath.row == 0){
			//website
			[AppDelegate loadWebViewWithURL:@"http://mobile.msnsportsnet.com/teams.cfm?sport=football" andTitle:@"WVU Football Team"];
		}
		else if(indexPath.row == 1){
			//roster
			[AppDelegate loadWebViewWithURL:@"http://mobile.msnsportsnet.com/page.cfm?sport=football&show=roster" andTitle:@"WVU Football Roster"];
		}
		else if(indexPath.row == 2){
			//tickets
			[AppDelegate loadWebViewWithURL:@"https://www.ticketreturn.com/wvu/" andTitle:@"Student Tickets"];
		}
		else if(indexPath.row == 3){
			//open Stewart's twitter feed
			TwitterBubbleViewController *viewController = [[TwitterBubbleViewController alloc] initWithUserName:@"CoachStewart"];
			viewController.tableView.delegate = viewController;
			viewController.tableView.dataSource = viewController;
			viewController.navigationItem.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
			[AppDelegate.navigationController pushViewController:viewController animated:YES];
			[viewController release];
		}
		else if(indexPath.row == 4){
			//
			BuildingLocationController *theBuildingView = [[BuildingLocationController alloc] initWithNibName:@"BuildingLocation" bundle:nil];
			NSString *buildingName = @"Football Stadium";
			theBuildingView.buildingName = buildingName;
			theBuildingView.navigationItem.title = buildingName;
			[AppDelegate.navigationController pushViewController:theBuildingView animated:YES];
			[theBuildingView release];
			
		}
	}
	else if(indexPath.section == 1){
		switch (indexPath.row) {
			case 0:
				// Liberty
				[AppDelegate loadWebViewWithURL:@"http://rivals.yahoo.com/ncaaf/teams/lle" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
				break;
			case 1:
				// East Carolina
				[AppDelegate loadWebViewWithURL:@"http://rivals.yahoo.com/ncaaf/teams/eea" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
				break;
			case 2:
				// Auburn
				[AppDelegate loadWebViewWithURL:@"http://rivals.yahoo.com/ncaaf/teams/aar" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
				break;
			case 3:
				break;
			case 4:
				// Colorado
				[AppDelegate loadWebViewWithURL:@"http://rivals.yahoo.com/ncaaf/teams/ccn" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
				break;
			case 5:
				// Syracuse
				[AppDelegate loadWebViewWithURL:@"http://rivals.yahoo.com/ncaaf/teams/ssw" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
				break;
			case 6:
				// Marshall
				[AppDelegate loadWebViewWithURL:@"http://rivals.yahoo.com/ncaaf/teams/mmc" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
				break;
			case 7:
				// Connecticut
				[AppDelegate loadWebViewWithURL:@"http://rivals.yahoo.com/ncaaf/teams/ccq" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
				break;
			case 8:
				// USF
				[AppDelegate loadWebViewWithURL:@"http://rivals.yahoo.com/ncaaf/teams/sbn" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
				break;
			case 9:
				// Louisville
				[AppDelegate loadWebViewWithURL:@"http://rivals.yahoo.com/ncaaf/teams/llh" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
				break;
			case 10:
				// Cincinnati
				[AppDelegate loadWebViewWithURL:@"http://rivals.yahoo.com/ncaaf/teams/ccj" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
				break;
			case 11:
				break;
			case 12:
				// Pittsburgh
				[AppDelegate loadWebViewWithURL:@"http://rivals.yahoo.com/ncaaf/teams/ppd" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
				break;
			case 13:
				// Rutgers
				[AppDelegate loadWebViewWithURL:@"http://rivals.yahoo.com/ncaaf/teams/rrd" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
				break;
			default:
				break;
		}
	}
	
	
	
	
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




-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if(section==1){
		return @"2009 Schedule";
	}
	
	return nil;
}


-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	if(section==1){
		return @"Links point to rivals.com";
	}
	
	return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if((indexPath.section == 1) && ((indexPath.row == 3) || (indexPath.row == 11))){
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		return nil;
	}
	return indexPath;
}



- (void)dealloc {
    [super dealloc];
}


@end

