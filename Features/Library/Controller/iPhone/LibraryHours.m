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
#import "DiningLocation.h"


@implementation LibraryHours







- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 4;	
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 6;
			break;
		case 2:
			return 6;
			break;
		case 3:
			return 1;
			break;
	}
	return 0;
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if (1==section) {
		return @"Ask a Librarian";
	}
	else if(2==section){
		return @"Links";
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	[AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	NSString *mainText = @"";
	NSString *subText = @"";
	
	
	// Set up the cell...
	switch (indexPath.section) {
		case 0:
			mainText = @"Library Hours";
			break;
		case 1:
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
				case 3:
					mainText = @"Email";
					break;
				case 4:
					mainText = @"Instant Message";
					break;
				case 5:
					mainText = @"Text Message";
					break;
			}
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
					mainText = @"Find an Open Computer";
					break;
				case 4:
					mainText = @"Number of Open Computers";
					break;
				case 5:
					mainText = @"Library Calendar";
					break;
			}
			break;
		case 3:
			mainText = @"Eliza's";
			break;
		
	}
	
	
	cell.textLabel.text = mainText;
	cell.detailTextLabel.text = subText;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	iWVUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if(indexPath.section == 0) {
		OPENURL(@"http://m.lib.wvu.edu/hours/")
	}
	else if(indexPath.section == 1){
		if (indexPath.row <= 2) {
			NSString *phoneNum = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
			[appDelegate callPhoneNumber:phoneNum];
		}
		else if(indexPath.row == 3){
			[appDelegate composeEmailTo:@"ask_a_librarian@mail.wvu.edu" withSubject:nil andBody:nil];
		}
		else if(indexPath.row == 4){
			OPENURL(@"http://m.lib.wvu.edu/ask/im.php");
		}
		else if(indexPath.row == 5){
			NSString *smsURL  = [NSString stringWithFormat:@"sms:%@?body=%@", @"+265010", [@"wvulibraries: " stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			[appDelegate callExternalApplication:@"Messages" withURL:smsURL];
		}
	}
	else if(indexPath.section == 2) {
		if (indexPath.row==0) {
			OPENURL(@"http://m.lib.wvu.edu/")
		}
		else if(indexPath.row == 1){
			OPENURL(@"http://mountainlynx.lib.wvu.edu/vwebv/searchBasic?sk=mobile")
		}
		else if(indexPath.row == 2){
			OPENURL(@"http://www.libraries.wvu.edu/maps/")
		}
		else if(indexPath.row == 3){
			OPENURL(@"http://systems.lib.wvu.edu/availableComputers/")
		}
		else if(indexPath.row == 4){
			OPENURL(@"http://m.lib.wvu.edu/available/")
		}
		else if(indexPath.row == 5){
			OPENURL(@"http://www.libraries.wvu.edu/hours/index.php?library=1")
		}
	}
	else if(indexPath.section == 3){
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		DiningLocation *theLoc = [[DiningLocation alloc] initWithStyle:UITableViewStyleGrouped];
		theLoc.locationName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
		theLoc.navigationItem.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
		[self.navigationController pushViewController:theLoc animated:YES];
	}
	
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	//these are the default's, but I'm going to explicitly define them, just to be safe
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		return (UIInterfaceOrientationPortrait == interfaceOrientation);
	}
	return YES;
}




@end
