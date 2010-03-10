//
//  SportViewController.m
//  iWVU
//
//  Created by Jared Crawford on 3/6/10.
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

#import "SportViewController.h"
#import "TwitterBubbleViewController.h"
#import "CalendarViewController.h"
#import "SQLite.h"
#import "BuildingLocationController.h"



@implementation SportViewController

@synthesize sportData;


- (id)initWithSportData:(NSDictionary *)data	{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.sportData = data;
    }
    return self;
}


/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 5;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
		return 2;
	}
	
	if(section == 1){
		return 2;
	}
	
	if(section == 2){
		NSString *twitterName = [sportData valueForKey:@"twitterName"];
		if(twitterName && ![twitterName isEqualToString:@""]){
			return 1;
		}
		return 0;
	}
	
	if(section == 3){
		NSString *tickets = [sportData valueForKey:@"ticketURL"];
		NSString *studentTickets = [sportData valueForKey:@"studentTicketURL"];
		int numRows = 0;
		if(tickets && ![tickets isEqualToString:@""]){
			numRows++;
		}
		if(studentTickets && ![studentTickets isEqualToString:@""]){
			numRows++;
		}
		return numRows;
	}
	
	if(section == 4){
		NSString *location = [sportData valueForKey:@"location"];
		if(location && ![location isEqualToString:@""]){
			return 1;
		}
		return 0;
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
    
    iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
	
	cell.textLabel.text = @"";
	cell.detailTextLabel.text =@"";
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	
	
	
	
	if(indexPath.section == 0){
		if(indexPath.row == 0){
			cell.textLabel.text = @"Team Website";
		}
		else{
			cell.textLabel.text = @"Team Roster";
		}
	}
	else if(indexPath.section == 1){
		if(indexPath.row == 0){
			cell.textLabel.text = @"Schedule";
		}
		else{
			cell.textLabel.text = @"Calendar";
		}
	}
	else if(indexPath.section == 2){
		cell.textLabel.text = [sportData valueForKey:@"twitterName"];
		cell.detailTextLabel.text = [@"@" stringByAppendingString:[sportData valueForKey:@"twitterAccount"]];
	}
	else if(indexPath.section == 3){
		NSString *tickets = [sportData valueForKey:@"ticketURL"];
		NSString *studentTickets = [sportData valueForKey:@"studentTicketURL"];
		
		NSString *general = @"General Admission Tickets";
		NSString *students = @"Student Tickets";
		
		if([self tableView:tableView numberOfRowsInSection:indexPath.section] == 1){
			if(tickets && ![tickets isEqualToString:@""]){
				cell.textLabel.text = general;
			}
			if(studentTickets && ![studentTickets isEqualToString:@""]){
				cell.textLabel.text = students;
			}
		}
		else {
			if(indexPath.row == 0){
				cell.textLabel.text = general;
			}
			else {
				cell.textLabel.text = students;
			}

		}
	}
	else if(indexPath.section == 4){
		cell.textLabel.text = @"Facility";
		cell.detailTextLabel.text = [sportData valueForKey:@"location"];
	}
	
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	
	if(indexPath.section == 0){
		
		if(indexPath.row == 0){
			NSString *teamWebsite = [sportData valueForKey:@"url"];
			OPENURL(teamWebsite);
		}
		else{
			NSString *teamWebsite = [sportData valueForKey:@"rosterURL"];
			OPENURL(teamWebsite);
		}
	}
	else if(indexPath.section == 1){
		if(indexPath.row == 0){
			NSString *teamWebsite = [sportData valueForKey:@"scheduleURL"];
			OPENURL(teamWebsite);
		}
		else{
			[SQLite initialize];
			NSString *query = @"SELECT * FROM \"Calendars\" WHERE \"category\" LIKE \"Athletics\"";
			NSArray *rowForCalendarKey = [SQLite query:query].rows;
			NSString *urlKey = nil;
			NSString *currentSport = [sportData valueForKey:@"sport"];
			NSLog(currentSport);
			for(NSDictionary *dict in rowForCalendarKey){
				NSString *aSport = [dict valueForKey:@"name"];
				NSLog(aSport);
				if([aSport isEqualToString:currentSport]){
					urlKey = [dict valueForKey:@"url"];
					break;
				}
			}
			if(urlKey){
				CalendarViewController *viewController = [[CalendarViewController alloc] init];
				viewController.calendarKey = urlKey;
				viewController.navigationItem.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
				[self.navigationController pushViewController:viewController animated:YES];
				[viewController release];
			}
			
			
		}
	}
	else if(indexPath.section == 2){
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		NSString *userName = [cell.detailTextLabel.text substringFromIndex:1];
		TwitterBubbleViewController *viewController = [[TwitterBubbleViewController alloc] initWithUserName:userName];
		viewController.navigationItem.title = cell.textLabel.text;
		[self.navigationController pushViewController:viewController animated:YES];
		[viewController release];
	}
	else if(indexPath.section == 3){
		NSString *tickets = [sportData valueForKey:@"ticketURL"];
		NSString *studentTickets = [sportData valueForKey:@"studentTicketURL"];
		if([self tableView:tableView numberOfRowsInSection:indexPath.section] == 1){
			if(tickets && ![tickets isEqualToString:@""]){
				OPENURL(tickets);
			}
			if(studentTickets && ![studentTickets isEqualToString:@""]){
				OPENURL(studentTickets);
			}
		}
		else {
			if(indexPath.row == 0){
				OPENURL(tickets);
			}
			else {
				OPENURL(studentTickets);
			}
			
		}
	}
	else if(indexPath.section == 4){
		BuildingLocationController *theBuildingView = [[BuildingLocationController alloc] initWithNibName:@"BuildingLocation" bundle:nil];
		NSString *buildingName = [sportData valueForKey:@"location"];
		theBuildingView.buildingName = buildingName;
		theBuildingView.navigationItem.title = buildingName;
		[self.navigationController pushViewController:theBuildingView animated:YES];
		[theBuildingView release];
		
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


- (void)dealloc {
    [super dealloc];
}


@end

