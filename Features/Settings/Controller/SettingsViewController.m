//
//  SettingsViewController.m
//  iWVU
//
//  Created by Jared Crawford on 3/15/10.
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

#import "SettingsViewController.h"
#import "MainScreen.h"
#import "LicenseViewController.h"

#if BETA_UPDATE_FRAMEWORK_ENABLED
#import "BWHockeyController.h"
#endif


@implementation SettingsViewController




- (void)viewDidLoad {
    [super viewDidLoad];

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
    #if BETA_UPDATE_FRAMEWORK_ENABLED
		return 3;
	#endif
	return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 1){
		return 3;
	}
	return 1;
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.detailTextLabel.textColor = [UIColor whiteColor];
	
	if(indexPath.section == 0){
		cell.textLabel.text = @"Reset Icon Configuration";
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else if(indexPath.section == 1){
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		if(indexPath.row == 0){
			cell.textLabel.text = @"Source Code";
		}
		else if(indexPath.row == 1){
			cell.textLabel.text = @"License";
		}
		else if(indexPath.row == 2){
			cell.textLabel.text = @"Request a feature";
		}
	}
	else if(indexPath.section == 2){
		cell.textLabel.text = @"Check for Update";
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if(indexPath.section == 0){
		[self resetConfiguration];
	}
	else if(indexPath.section == 1){
		if(indexPath.row == 0){
			OPENURL(@"http://github.com/JaredCrawford/iWVU");
		}
		else if(indexPath.row == 1){
			LicenseViewController *viewController = [[LicenseViewController alloc] initWithStyle:UITableViewStylePlain];
			viewController.navigationItem.title = @"License";
			[self.navigationController pushViewController:viewController animated:YES];
			[viewController release];
		}
		else if(indexPath.row == 2){
			iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
			[AppDelegate composeEmailTo:@"iWVU@JaredCrawford.org" withSubject:@"Feature Request" andBody:nil];
		}
	}
	else if(indexPath.section == 2){
		#if BETA_UPDATE_FRAMEWORK_ENABLED
		BWHockeyViewController *hockeyViewController = [[BWHockeyController sharedHockeyController] hockeyViewController:NO];
		[self.navigationController pushViewController:hockeyViewController animated:YES];
		#endif
	}
	
}

-(void)resetConfiguration{
	for(UIViewController *viewController in self.navigationController.viewControllers){
		if([viewController isKindOfClass:[MainScreen class]]){
			[((MainScreen *)viewController).launcherView createDefaultView];
		}
			
	}

}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 0){
		return @"Main Screen";
	}
	else if(section == 1){
		return @"About iWVU";
	}
	else if(section == 2){
#if BETA_UPDATE_FRAMEWORK_ENABLED
		return @"Beta Testing";
#endif
	}
	return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	if(section == 0){
		return @"Restores the icons on the main screen to their default configuration.";
	}
	return nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	//these are the default's, but I'm going to explicitly define them, just to be safe
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		return NO;
	}
	return YES;
}


- (void)dealloc {
    [super dealloc];
}


@end

