//
//  DiningList.m
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

#import "DiningList.h"
#import "DiningLocation.h"


@implementation DiningList


/*
TODO
 *Add non-WVU Dining Services Locations (Sbarro's and Sidepocket)
 *Update the information on Quiznos
*/



-(void)viewDidAppear:(BOOL)animated{
	NSError *anError;
	[[GANTracker sharedTracker] trackPageview:@"/Main/DiningList" withError:&anError];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	theTollbar.tintColor = [UIColor WVUBlueColor];
	sortControl.tintColor = [UIColor WVUBlueColor];
	
	NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"PaymentType.plist"];
	PaymentType = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
	
	
	
	
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
	
}


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
	[PaymentType release];
	[MealPlanLocations release];
}


- (void)dealloc {
    [super dealloc];
}



-(IBAction)sortingChanged:(UISegmentedControl *)sender{
	//
	[theTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
	[theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0	inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}






- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//section 1 was used due to ads conflicting with section header
	//this should be changed
	if(section == 1){
		NSString *selectedSort = [sortControl titleForSegmentAtIndex:sortControl.selectedSegmentIndex];
		if([selectedSort isEqualToString:@"All"]){
			return [PaymentType count];
		}
		else if([selectedSort isEqualToString:@"Meal Plan"]){
			return [MealPlanLocations count];
		}
	}
	return 0;
}
	



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	
	cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	
	NSString *mainLabel = @"";
	NSString *secondaryLabel = @"";
	
	
	
	
	
	NSString *selectedSort = [sortControl titleForSegmentAtIndex:sortControl.selectedSegmentIndex];
	if([selectedSort isEqualToString:@"All"]){
		NSArray *locations = [PaymentType allKeys];
		mainLabel = [locations objectAtIndex:indexPath.row];
	}
	else if([selectedSort isEqualToString:@"Meal Plan"]){
		mainLabel = [MealPlanLocations objectAtIndex:indexPath.row];
	}
	
	
	
	cell.textLabel.text = mainLabel;
	cell.detailTextLabel.text = secondaryLabel;
	
	return cell;
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	DiningLocation *theLoc = [[DiningLocation alloc] initWithStyle:UITableViewStyleGrouped];
	theLoc.locationName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
	theLoc.navigationItem.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
	[self.navigationController pushViewController:theLoc animated:YES];
	[theLoc release];
}





- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 1){
		NSString *selectedSort = [sortControl titleForSegmentAtIndex:sortControl.selectedSegmentIndex];
		if([selectedSort isEqualToString:@"All"]){
			return @"WVU Dining Services Locations";
		}
		else if([selectedSort isEqualToString:@"Meal Plan"]){
			return @"Meal Plan Locations";
		}
	}
	return nil;
}

@end
