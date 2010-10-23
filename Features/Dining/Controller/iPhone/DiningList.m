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
#import "SQLite.h"


@implementation DiningList


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	theTollbar.tintColor = [UIColor WVUBlueColor];
	sortControl.tintColor = [UIColor WVUBlueColor];
	
	[SQLite initialize];
	locations = [[SQLite query:@"SELECT * FROM \"Dining\""].rows retain];
	mealPlanLocations = [[SQLite query:@"SELECT * FROM \"Dining\" WHERE \"MealPlan\" IN (\"Y\")"].rows retain];
	
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}






-(IBAction)sortingChanged:(UISegmentedControl *)sender{
	//
	[theTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
	[theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0	inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	//these are the default's, but I'm going to explicitly define them, just to be safe
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		return (UIInterfaceOrientationPortrait == interfaceOrientation);
	}
	return YES;
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
		NSString *selectedSort = [sortControl titleForSegmentAtIndex:sortControl.selectedSegmentIndex];
		if(section == 0){
			return 0;
		}
		else if([selectedSort isEqualToString:@"All"]){
			return [locations count];
		}
		else{
			return [mealPlanLocations count];
		}
}
	

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	[AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	
	NSString *mainLabel = @"";
	NSString *secondaryLabel = @"";
	
	
	NSString *selectedSort = [sortControl titleForSegmentAtIndex:sortControl.selectedSegmentIndex];
	if([selectedSort isEqualToString:@"All"]){
		mainLabel = [[locations objectAtIndex:indexPath.row] valueForKey:@"Name"];
	}
	else{
		mainLabel = [[mealPlanLocations objectAtIndex:indexPath.row] valueForKey:@"Name"];
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


-(void)dealloc{
	[locations release];
	[mealPlanLocations release];
	[super dealloc];
}

@end
