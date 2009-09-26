//
//  LibraryHours.m
//  iWVU
//
//  Created by Jared Crawford on 6/11/09.
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

#import "LibraryHours.h"
#import "iWVUAppDelegate.h"
#import "WebViewController.h"
#import "LibraryHoursTable.h"
#import "DiningLocation.h"


@implementation LibraryHours







- (void)dealloc {
    [super dealloc];
}



/******************************************************
 *
 * table view data source methods
 *
 ******************************************************/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 5;
	
	//Ask a librarian - email
	
	//links
		//website
		//search
		//Library Calendar
		//reserve a room
		//Eliza's
	
	//phone numbers
		//####   downtown
		//evansdale
		//HSC
	
	
	
	
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 1;
			break;
		case 2:
			return 4;
			break;
		case 3:
			return 3;
			break;
		case 4:
			return 1;
			break;
	}
	return 0;
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if(2==section){
		return @"Links";
	}
	else if(3==section){
		return @"Phone Numbers";
	}
	return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	iWVUAppDelegate *AppDelegate = [[UIApplication sharedApplication] delegate];
	cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
	
	NSString *mainText;
	NSString *subText = @"";
	
	
	// Set up the cell...
	switch (indexPath.section) {
		case 0:
			mainText = @"Library Hours";
			break;
		case 1:
			mainText = @"Ask A Librarian";
			subText = @"email";
			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					mainText = @"Libraries Website";
					break;
				case 1:
					mainText = @"Book Search";
					break;
				case 2:
					mainText = @"Library Map";
					break;
				case 3:
					mainText = @"Library Calendar";
					break;
			}
			break;
		case 3:
			switch (indexPath.row) {
				case 0:
					subText = @"(304) 293-3640";
					mainText = @"Downtown";
					break;
				case 1:
					subText = @"(304) 293-4695";
					mainText = @"Evansdale";
					break;
				case 2:
					subText = @"(304) 293-6810";
					mainText = @"Health Sciences";
					break;
			}
			break;
		case 4:
			mainText = @"Eliza's";
			break;
		
	}
	
	
	cell.textLabel.text = mainText;
	cell.detailTextLabel.text = subText;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
	
}

/******************************************************
 *
 * table view delegate methods
 *
 ******************************************************/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	iWVUAppDelegate *AppDelegate = [[UIApplication sharedApplication] delegate];
	switch (indexPath.section) {
		case 0:
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			LibraryHoursTable *theView = [[LibraryHoursTable alloc] initWithNibName:@"LibraryHours" bundle:nil];
			theView.navigationItem.title = @"Library Hours";
			UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Hours" style:UIBarButtonItemStyleBordered target:nil action:nil];
			theView.navigationItem.backBarButtonItem = backButton;
			[backButton release];
			[AppDelegate.navigationController pushViewController:theView animated:YES];
			[theView release];
			break;
		case 1:
			if(indexPath.row == 0){
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				[AppDelegate composeEmailTo:@"ask_a_librarian@mail.wvu.edu" withSubject:nil andBody:nil];
			}
			break;
		case 2:
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			switch (indexPath.row) {
				case 0:
					[AppDelegate loadWebViewWithURL:@"http://www.libraries.wvu.edu/" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
					break;
				case 1:
					[AppDelegate loadWebViewWithURL:@"http://mountainlynx.lib.wvu.edu/vwebv/searchBasic" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
					break;
				case 2:
					[AppDelegate loadWebViewWithURL:@"http://www.libraries.wvu.edu/maps/" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
					break;
				case 3:
					[AppDelegate loadWebViewWithURL:@"http://www.libraries.wvu.edu/hours/index.php?library=1" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
					break;
				case 4:
					[AppDelegate loadWebViewWithURL:@"http://www.libraries.wvu.edu/elizas/index.htm" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
					break;
			}
			break;
			
			
			
			
		case 3:
			//
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			NSString *phoneNum = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
			[AppDelegate callPhoneNumber:phoneNum];
			break;
		case 4:
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			DiningLocation *theLoc = [[DiningLocation alloc] initWithStyle:UITableViewStyleGrouped];
			theLoc.locationName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
			theLoc.navigationItem.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
			/*UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Emergency" style:UIBarButtonItemStyleBordered	target:nil action:nil];
			 theServView.navigationItem.backBarButtonItem = abackButton;
			 [abackButton release];
			 */
			[AppDelegate.navigationController pushViewController:theLoc animated:YES];
			[theLoc release];
			break;
	}
		
}

/******************************************************
 *
 * web view delegate methods
 *
 ******************************************************/



@end
