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



@implementation DiningLocation

@synthesize locationName;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/



-(void)viewDidAppear:(BOOL)animated{
	NSError *anError;
	NSString *pageName = [NSString stringWithFormat:@"/Main/DiningList/%@", locationName];
	[[GANTracker sharedTracker] trackPageview:pageName withError:&anError];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"PaymentType.plist"];
	NSDictionary *PaymentType = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
	
	
	NSMutableArray *MPLocs = [NSMutableArray array];
	for(NSString *location in PaymentType){
		NSString *payments = [PaymentType objectForKey:location];
		for(int j=0;j<[payments length];j++){
			if('M' == [payments characterAtIndex:j]){
				[MPLocs addObject:location];
			}
		}
	}
	
	MealPlanLocations = [[NSArray alloc] initWithArray:MPLocs];
	
	
	
	
	NSMutableArray *MlzPlusLocs = [NSMutableArray array];
	for(NSString *location in PaymentType){
		NSString *payments = [PaymentType objectForKey:location];
		for(int j=0;j<[payments length];j++){
			if('P' == [payments characterAtIndex:j]){
				[MlzPlusLocs addObject:location];
			}
		}
	}
	
	MealsPlusLocations = [[NSArray alloc] initWithArray:MlzPlusLocs];
	
	
	
	
	NSMutableArray *MBLocs = [NSMutableArray array];
	for(NSString *location in PaymentType){
		NSString *payments = [PaymentType objectForKey:location];
		for(int j=0;j<[payments length];j++){
			if('B' == [payments characterAtIndex:j]){
				[MBLocs addObject:location];
			}
		}
	}
	
	MountieBountyLocations = [[NSArray alloc] initWithArray:MBLocs];
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
	 
	 Hours
	 
	 Payment Type
	 
	 Location
	 Phone Number
	 */
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
		if(([locationName isEqualToString:@"Arnold's American Diner"])||
			([locationName isEqualToString:@"Boreman Bistro"])||
			([locationName isEqualToString:@"Café Evansdale"])||
			([locationName isEqualToString:@"Hatfield's"])||
			([locationName isEqualToString:@"Stalnaker"])||
			([locationName isEqualToString:@"Summit Café"])){
				return 2;
			}
		else{
			return 1;
		}
			
	}
	else if(section == 1){
		//hours
		NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"DiningHoursLine2Main.plist"];
		NSDictionary *dictFor2 = [NSDictionary dictionaryWithContentsOfFile:path];
		if([[dictFor2 objectForKey:locationName] isEqualToString:@""]){
			return 1;
		}
		path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"DiningHoursLine3Main.plist"];
		dictFor2 = [NSDictionary dictionaryWithContentsOfFile:path];
		if([[dictFor2 objectForKey:locationName] isEqualToString:@""]){
			return 2;
		}
		path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"DiningHoursLine4Main.plist"];
		dictFor2 = [NSDictionary dictionaryWithContentsOfFile:path];
		if([[dictFor2 objectForKey:locationName] isEqualToString:@""]){
			return 3;
		}
		return 4;
	}
	else if (section == 3){
		return 6;
	}
	else if(section == 2){
		NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"DiningPhone.plist"];
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
		NSString *locationPhone = [dict objectForKey:locationName];
		if([@"" isEqualToString:locationPhone]){
			return 1;
		}
		return 2;
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
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.detailTextLabel.adjustsFontSizeToFitWidth = NO;
	cell.textLabel.adjustsFontSizeToFitWidth = NO;
    
    // Set up the cell...
	NSString *mainLabel = @"";
	NSString *detailLabel = @"";
	
	if(indexPath.section == 0){
		if(indexPath.row == 0){
			mainLabel = @"Website";
		}
		else if(indexPath.row == 1){
			mainLabel = @"Menu";
		}
	}
	else if(indexPath.section == 1){
		//
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		NSString *mainFileName = [NSString stringWithFormat:@"DiningHoursLine%dMain.plist",(indexPath.row + 1)];
		NSString *detailFileName = [NSString stringWithFormat:@"DiningHoursLine%dDetail.plist",(indexPath.row + 1)];
		NSString *mainPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:mainFileName];
		NSString *detailPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:detailFileName];
		NSDictionary *mainDict = [NSDictionary dictionaryWithContentsOfFile:mainPath];
		NSDictionary *detailDict = [NSDictionary dictionaryWithContentsOfFile:detailPath];
		mainLabel = [mainDict objectForKey:locationName];
		detailLabel = [detailDict objectForKey:locationName];
	}
	else if(indexPath.section == 3){
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		
		if(indexPath.row == 0){
			mainLabel = @"Meal Plan";
			for(NSString *loc in MealPlanLocations){
				if([locationName isEqualToString:loc]){
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				}
			}
		}
		if(indexPath.row == 1){
			mainLabel = @"Meals Plus";
			for(NSString *loc in MealsPlusLocations){
				if([locationName isEqualToString:loc]){
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				}
			}
		}
		if(indexPath.row == 2){
			mainLabel = @"Mountie Bounty";
			for(NSString *loc in MountieBountyLocations){
				if([locationName isEqualToString:loc]){
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				}
			}
		}
		if(indexPath.row == 3){
			mainLabel = @"Cash";
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
		if(indexPath.row == 4){
			mainLabel = @"Visa";
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
		if(indexPath.row == 5){
			mainLabel = @"MasterCard";
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
	}
	else if(indexPath.section == 2){
		if(indexPath.row == 0){
			mainLabel = @"Location";
			NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"DiningLocationPosition.plist"];
			NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
			detailLabel = [dict objectForKey:locationName];
			cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
			cell.textLabel.adjustsFontSizeToFitWidth = YES;
		}
		else if(indexPath.row == 1){
			mainLabel = @"Phone";
			NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"DiningPhone.plist"];
			NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
			detailLabel = [dict objectForKey:locationName];
		}
	}
	
	
	
	
	cell.textLabel.text = mainLabel;
	cell.detailTextLabel.text = detailLabel;
	
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
			NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"DiningWebsite.plist"];
			NSDictionary *websiteDict = [NSDictionary dictionaryWithContentsOfFile:path];
			NSString *website = [websiteDict objectForKey:locationName];
			OPENURL(website)
		}
		if(indexPath.row == 1){
			OPENURL(@"http://www.wvu.edu/~dining/Menu%20Page%202.htm")
		}
	}
	
	if(indexPath.section == 2){
		if(indexPath.row == 0){
			BuildingLocationController *theBuildingView = [[BuildingLocationController alloc] initWithNibName:@"BuildingLocation" bundle:nil];
			NSString *buildingName = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
			theBuildingView.buildingName = buildingName;
			theBuildingView.navigationItem.title = buildingName;
			[self.navigationController pushViewController:theBuildingView animated:YES];
			[theBuildingView release];
		}
		if(indexPath.row == 1){
			NSString *phoneNum = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
			[AppDelegate callPhoneNumber:phoneNum];
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


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 1){
		return @"Normal Operating Hours";
	}
	else if(section == 3){
		return @"Accepted Forms of Payment";
	}
	else if(section == 2){
		return @"Information";
	}
	return nil;
}




- (void)dealloc {
	[MealPlanLocations release];
	[MealsPlusLocations release];
	[MountieBountyLocations release];
    [super dealloc];
}





@end

