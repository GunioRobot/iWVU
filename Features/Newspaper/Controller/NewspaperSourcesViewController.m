//
//  NewspaperSourcesViewController.m
//  iWVU
//
//  Created by Jared Crawford on 3/9/10.
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

#import "NewspaperSourcesViewController.h"
#import "DAReaderViewController.h"
#import "NewspaperEngine.h"
#import "TwitterBubbleViewController.h"

@implementation NewspaperSourcesViewController




- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(![[userDefaults stringForKey:USER_DEFAULT_NEWSPAPER_CACHE_KEY] isEqualToString:USER_DEFAULT_NEWSPAPER_CACHE_NEGATIVE]){
		[userDefaults setObject:USER_DEFAULT_NEWSPAPER_CACHE_AFFIMATIVE forKey:USER_DEFAULT_NEWSPAPER_CACHE_KEY];
	}
	else {
		NewspaperEngine	*newsEngine = [[NewspaperEngine alloc] init];
		[newsEngine clearAllLocallyCachedPages];
		[newsEngine release];
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
    return 5;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.textAlignment = UITextAlignmentLeft;
	
    if(indexPath.section == 0){
		cell.textLabel.text = @"Daily Athenaeum Reader";
	}
	else if(indexPath.section == 1){
		cell.textLabel.text = @"theDAonline.com";
	}
	else if(indexPath.section == 2){
		cell.textLabel.text = @"@DailyAthenaeum";
	}
	else if(indexPath.section == 3){
		cell.textLabel.text = @"Cache Pages";
		cell.accessoryType = UITableViewCellAccessoryNone;
		UISwitch *aSwitch = [[UISwitch alloc] init];
		float switchWidth = aSwitch.frame.size.width;
		float switchHeight = aSwitch.frame.size.height;
		aSwitch.frame = CGRectMake(cell.contentView.frame.size.width-switchWidth-30, (cell.contentView.frame.size.height-switchHeight)/2, switchWidth, switchHeight);
		[cell.contentView addSubview:aSwitch];
		
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		if([[userDefaults stringForKey:USER_DEFAULT_NEWSPAPER_CACHE_KEY] isEqualToString:USER_DEFAULT_NEWSPAPER_CACHE_NEGATIVE]){
			aSwitch.on = NO;
		}
		else {
			aSwitch.on = YES;
		}
		
		[aSwitch addTarget:self action:@selector(cachePreferenceChanged:) forControlEvents:UIControlEventValueChanged];
		[aSwitch release];
	}
	else if(indexPath.section == 4){
		cell.textLabel.text = @"Clear All Cached Pages";
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    return cell;
}


-(void)cachePreferenceChanged:(UISwitch *)switcher{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if(switcher.on){
		[userDefaults setObject:USER_DEFAULT_NEWSPAPER_CACHE_AFFIMATIVE forKey:USER_DEFAULT_NEWSPAPER_CACHE_KEY];
	}
	else{
		[userDefaults setObject:USER_DEFAULT_NEWSPAPER_CACHE_NEGATIVE forKey:USER_DEFAULT_NEWSPAPER_CACHE_KEY];
		NewspaperEngine	*newsEngine = [[NewspaperEngine alloc] init];
		[newsEngine clearAllLocallyCachedPages];
		[newsEngine release];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 1){
		return @"Mobile Website";
	}
	else if(section == 2){
		return @"Twitter";
	}
	else if(section == 3){
		return @"Settings";
	}
	return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if(indexPath.section == 0){
		DAReaderViewController *aDAReader = [[DAReaderViewController alloc] initWithNibName:@"DAReaderView" bundle:nil];
		aDAReader.navigationItem.title = @"The DA";
		UIBarButtonItem *aBackButton = [[UIBarButtonItem alloc] initWithTitle:@"The DA" style:UIBarButtonItemStyleBordered target:nil action:nil];
		aDAReader.navigationItem.backBarButtonItem = aBackButton;
		[aBackButton release];
		[self.navigationController pushViewController:aDAReader animated:YES];
		[aDAReader release];
	}
	else if(indexPath.section == 1){
		OPENURL(@"http://www.thedaonline.com/");
	}
	else if(indexPath.section == 2){
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		NSString *userName = [cell.textLabel.text substringFromIndex:1];
		TwitterBubbleViewController *viewController = [[TwitterBubbleViewController alloc] initWithUserName:userName];
		viewController.navigationItem.title = cell.textLabel.text;
		[self.navigationController pushViewController:viewController animated:YES];
		[viewController release];
	}
	else if(indexPath.section == 4){
		NewspaperEngine	*newsEngine = [[NewspaperEngine alloc] init];
		[newsEngine clearAllLocallyCachedPages];
		[newsEngine release];
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

