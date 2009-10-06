//
//  MainTableView.m
//  iWVU
//
//  Created by Jared Crawford on 6/9/09.
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

#import "MainTableView.h"

#import "iWVUAppDelegate.h"


//section 1

#import "BuildingList.h"
#import "LibraryHours.h"
#import "FootballSchedule.h"
#import "PRTinfo.h"
#import "U92Controller.h"
#import "BusesMain.h"
#import "EmergencyServices.h"
#import "DirectorySearch.h"
#import "DiningList.h"
#import "DAReaderViewController.h"
#import "MapFromBuildingListDriver.h"
#import "TwitterUserListViewController.h"

//section 2

#import "WebViewController.h"








@implementation MainTableView



- (void)viewDidLoad {
    [super viewDidLoad];
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	
	
	//This only runs if standardUserDefaults are empty
	//It can be a bit confusing, so look at "registerDefaults" in the API
	NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"MainScreenOrder.plist"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:path]];
	
	
	//Reset the screen sorting order on the first launch of a new version.
	if(![@"2.0" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"AppVersion"]]){
		[[NSUserDefaults standardUserDefaults] setObject:@"2.0" forKey:@"AppVersion"];
		for(NSString *aKey in [[NSUserDefaults standardUserDefaults] dictionaryRepresentation] ){
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:aKey];
		}
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
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case 0:
			return 12;
			break;
		case 1:
			return 9;
			break;
		default:
			return 0;
			break;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
	
	
	NSString *IconPath = [[NSBundle mainBundle] bundlePath];
	
	NSString *key = [NSString stringWithFormat:@"MainScreenSeg%dRow%d",indexPath.section, indexPath.row];
	NSString *rowName = [[NSUserDefaults standardUserDefaults] objectForKey:key];

	iWVUAppDelegate *AppDelegate = [[UIApplication sharedApplication] delegate];
	
    // Set up the cell...
	if(indexPath.section==0) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"TopSectionCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TopSectionCell"] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
			cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
			cell.showsReorderControl = YES;
			cell.shouldIndentWhileEditing = NO;
		
		if(indexPath.row%2 == 1){
			cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUMainPageYellow.png"]] autorelease];
			cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUMainPageBlue.png"]] autorelease];
			cell.detailTextLabel.textColor = [UIColor blackColor];
			cell.textLabel.highlightedTextColor = [UIColor colorWithRed:1 green:.8 blue:0 alpha:1];
			cell.textLabel.textColor = [UIColor colorWithRed:0 green:.2 blue:.4 alpha:1];
		}
		else{
			cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUMainPageYellow.png"]] autorelease];
			cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUMainPageBlue.png"]] autorelease];
			cell.textLabel.textColor = [UIColor colorWithRed:1 green:.8 blue:0 alpha:1];
			cell.detailTextLabel.textColor = [UIColor blackColor];
			cell.textLabel.textColor = [UIColor colorWithRed:1 green:.8 blue:0 alpha:1];
			cell.textLabel.highlightedTextColor = [UIColor colorWithRed:0 green:.2 blue:.4 alpha:1];
		 }
			
			UIImage *image;
			
			if([rowName isEqualToString:@"Buildings"]){
				image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"Building.png"]];					
			}
			
			else if([rowName isEqualToString:@"U92"]){
				image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"Radio.png"]];
			}
			
			else if([rowName isEqualToString:@"Directory"]){
				image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"Search.png"]];
			}	
			
			else if([rowName isEqualToString:@"Twitter"]){
				image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"Twitter.png"]];
			}
			
			else if([rowName isEqualToString:@"PRT"]){
				image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"PRT.png"]];
			}
			
			else if([rowName isEqualToString:@"Buses"]){
				image =  [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"Bus.png"]];
			}
			
			else if([rowName isEqualToString:@"Libraries"]){
				image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"Book.png"]];
			}
			else if([rowName isEqualToString:@"Football"]){
				image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"Football.png"]];
			}
			
			else if([rowName isEqualToString:@"Basketball"]){
				image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"Basketball.png"]];
			}
			
			else if([rowName isEqualToString:@"Weather"]){
				image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"Weather.png"]];
			}
			
			else if([rowName isEqualToString:@"Colleges"]){
				image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"Department.png"]];
			}
			
			else if([rowName isEqualToString:@"Rec Center"]){
				image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"Weights.png"]];
			}
			else if([rowName isEqualToString:@"Emergency Services"]){
				image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"Police.png"]];
			}
			
			else if([rowName isEqualToString:@"Dining"]){
				image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"Food.png"]];
			}
			else if ([rowName isEqualToString:@"WVU Mobile"]){
				image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"MobileSite.png"]];
			}
			else if ([rowName isEqualToString:@"The DA"]){
				image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"DAReader.png"]];
			}

		
		cell.imageView.image = image;
		rowName = [@"  " stringByAppendingString:rowName];	
			
	}
	else if(indexPath.section == 1){
		cell = [tableView dequeueReusableCellWithIdentifier:@"BottomSectionCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BottomSectionCell"] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

		
		}	
		
		cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
		
		cell.imageView.image = nil;
	}
	
	
	cell.shouldIndentWhileEditing = NO;
	cell.textLabel.text = rowName;
		
	
      return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	iWVUAppDelegate *AppDelegate = [[UIApplication sharedApplication] delegate];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString *title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
	
	switch (indexPath.section){
		case 0:
			
			title = [title substringFromIndex:2];
			
			if([@"Buildings" isEqualToString:title]){
				MapFromBuildingListDriver *aDriver = [[MapFromBuildingListDriver alloc] init];
				BuildingList *theBuildingView = [[BuildingList alloc] initWithDelegate:aDriver];
				theBuildingView.navigationItem.title = @"Building Finder";
				UIBarButtonItem *backBuildingButton = [[UIBarButtonItem alloc] initWithTitle:@"Buildings" style:UIBarButtonItemStyleBordered	target:nil action:nil];
				theBuildingView.navigationItem.backBarButtonItem = backBuildingButton;
				[backBuildingButton release];
				[AppDelegate.navigationController pushViewController:theBuildingView animated:YES];
				[theBuildingView release];
			}
			else if([@"Buses" isEqualToString:title]){
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				BusesMain *theBusesView = [[BusesMain alloc] initWithStyle:UITableViewStyleGrouped];
				theBusesView.navigationItem.title = @"Mountain Line Buses";
				UIBarButtonItem *backBusesButton = [[UIBarButtonItem alloc] initWithTitle:@"Buses" style:UIBarButtonItemStyleBordered	target:nil action:nil];
				theBusesView.navigationItem.backBarButtonItem = backBusesButton;
				[backBusesButton release];
				[AppDelegate.navigationController pushViewController:theBusesView animated:YES];
				[theBusesView release];
			}
			else if([@"U92" isEqualToString:title]){
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				U92Controller *u92view = [[U92Controller alloc] initWithStyle:UITableViewStyleGrouped];
				u92view.navigationItem.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
				[AppDelegate.navigationController pushViewController:u92view animated:YES];
				[u92view release];
			}
			else if([@"PRT" isEqualToString:title]){
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				PRTinfo *PRTview = [[PRTinfo alloc] initWithStyle:UITableViewStyleGrouped];
				PRTview.navigationItem.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
				UIBarButtonItem *PRTviewButton = [[UIBarButtonItem alloc] initWithTitle:@"PRT" style:UIBarButtonItemStyleBordered	target:nil action:nil];
				PRTview.navigationItem.backBarButtonItem = PRTviewButton;
				[PRTviewButton release];
				[AppDelegate.navigationController pushViewController:PRTview animated:YES];
				[PRTview release];
			}
			else if([@"Libraries" isEqualToString:title]){
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				LibraryHours *theView = [[LibraryHours alloc] initWithStyle:UITableViewStyleGrouped];
				theView.navigationItem.title = @"WVU Libraries";
				UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStyleBordered	target:nil action:nil];
				theView.navigationItem.backBarButtonItem = backButton;
				[backButton release];
				[AppDelegate.navigationController pushViewController:theView animated:YES];
				[theView release];
			}
			else if([@"Football" isEqualToString:title]){
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				FootballSchedule *theSchedule = [[FootballSchedule alloc] initWithStyle:UITableViewStyleGrouped];
				theSchedule.navigationItem.title = @"WVU Football";
				UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Football" style:UIBarButtonItemStyleBordered	target:nil action:nil];
				theSchedule.navigationItem.backBarButtonItem = abackButton;
				[abackButton release];
				[AppDelegate.navigationController pushViewController:theSchedule animated:YES];
				[theSchedule release];
			}
			else if([@"Emergency Services" isEqualToString:title]){
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				EmergencyServices *theServView = [[EmergencyServices alloc] initWithStyle:UITableViewStyleGrouped];
				theServView.navigationItem.title = @"Emergency Services";
				UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Emergency" style:UIBarButtonItemStyleBordered	target:nil action:nil];
				theServView.navigationItem.backBarButtonItem = abackButton;
				[abackButton release];
				[AppDelegate.navigationController pushViewController:theServView animated:YES];
				[theServView release];
			}
			else if([@"Directory" isEqualToString:title]){
				//
				DirectorySearch *dirSer = [[DirectorySearch alloc] initWithNibName:@"DirectorySearch" bundle:nil];
				dirSer.navigationItem.title = @"Directory Search";
				UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Directory" style:UIBarButtonItemStyleBordered	target:nil action:nil];
				dirSer.navigationItem.backBarButtonItem = abackButton;
				[abackButton release];
				[AppDelegate.navigationController pushViewController:dirSer animated:YES];
				[dirSer release];
			}
			else if([@"Dining" isEqualToString:title]){
				//
				DiningList *dinList = [[DiningList alloc] initWithNibName:@"DiningList" bundle:nil];
				dinList.navigationItem.title = @"On-Campus Dining";
				UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Dining" style:UIBarButtonItemStyleBordered	target:nil action:nil];
				dinList.navigationItem.backBarButtonItem = abackButton;
				[abackButton release];
				[AppDelegate.navigationController pushViewController:dinList animated:YES];
				[dinList release];
			}
			else if([@"WVU Mobile" isEqualToString:title]){
				[AppDelegate loadWebViewWithURL:@"http://m.wvu.edu" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
			}
			else if([@"The DA" isEqualToString:title]){
				DAReaderViewController *aDAReader = [[DAReaderViewController alloc] initWithNibName:@"DAReaderView" bundle:nil];
				aDAReader.navigationItem.title = @"The DA";
				UIBarButtonItem *aBackButton = [[UIBarButtonItem alloc] initWithTitle:@"The DA" style:UIBarButtonItemStyleBordered target:nil action:nil];
				aDAReader.navigationItem.backBarButtonItem = aBackButton;
				[aBackButton release];
				[AppDelegate.navigationController pushViewController:aDAReader animated:YES];
				[aDAReader release];
			}
			else if([@"Twitter" isEqualToString:title]){
				TwitterUserListViewController *twitterUsers = [[TwitterUserListViewController alloc] initWithStyle:UITableViewStyleGrouped];
				twitterUsers.navigationItem.title = @"Twitter";
				[AppDelegate.navigationController pushViewController:twitterUsers animated:YES];
				[twitterUsers release];
			}
			break;
		case 1:
			if([@"WVU.edu" isEqualToString:title]){
				[AppDelegate loadWebViewWithURL:@"http://www.wvu.edu" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
			}
			else if([@"WVU Today" isEqualToString:title]){
				[AppDelegate loadWebViewWithURL:@"http://wvutoday.wvu.edu" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
				//
			}
			else if([@"Course Catalog" isEqualToString:title]){
				[AppDelegate loadWebViewWithURL:@"http://coursecatalog.wvu.edu/" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
			}
			else if([@"WVU Alert" isEqualToString:title]){
				[AppDelegate loadWebViewWithURL:@"http://alert.wvu.edu" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
			}
			else if([@"MSNSportsNET" isEqualToString:title]){
				[AppDelegate loadWebViewWithURL:@"http://msnsportsnet.com/" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
			}
			else if([@"MIX" isEqualToString:title]){
				[AppDelegate loadWebViewWithURL:@"http://mix.wvu.edu/" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
			}
			else if([@"eCampus" isEqualToString:title]){
				[AppDelegate loadWebViewWithURL:@"http://ecampus.wvu.edu/" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
			}
			else if([@"Weather" isEqualToString:title]){
				[AppDelegate loadWebViewWithURL:@"http://i.wund.com/cgi-bin/findweather/getForecast?brand=iphone&query=morgantown%2C+wv#conditions" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
			}
			else if([@"Calendar" isEqualToString:title]){
				[AppDelegate loadWebViewWithURL:@"http://calendar.wvu.edu" andTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
			}
			
	}
	
	
	
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return UITableViewCellEditingStyleNone;
}



// Support for rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
	iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	
	if(fromIndexPath.section != toIndexPath.section){
		//move it back
	}
	else{
	
		//A dictionary with all the changed cells in it, starting from the To and going to the from or vice versa
		NSMutableDictionary *updates = [NSMutableDictionary dictionary];
		
		//the cell that was actually moved
		NSString *OldLoacation = [NSString stringWithFormat:@"MainScreenSeg%dRow%d",fromIndexPath.section,fromIndexPath.row];
		NSString *OldPathTitle = [[NSUserDefaults standardUserDefaults] objectForKey:OldLoacation];
		NSString *newLocation = [NSString stringWithFormat:@"MainScreenSeg%dRow%d",toIndexPath.section,toIndexPath.row];
		[updates setValue:OldPathTitle forKey:newLocation];
		if(fromIndexPath.section != 0){
			[AppDelegate configureTableViewCell:[tableView cellForRowAtIndexPath:fromIndexPath] inTableView:tableView forIndexPath:toIndexPath];
		}
		//all the rest
		int from, to;
		
		from = fromIndexPath.row;
		to = toIndexPath.row;
		
		
		if(from>to){
			//moving a cell up
			for(int i = to; i < from ; i++){
				//loop through, updating each one's location
				NSIndexPath *OldPath = [NSIndexPath indexPathForRow:i inSection:fromIndexPath.section];
				NSIndexPath *NewPath = [NSIndexPath indexPathForRow:i+1 inSection:fromIndexPath.section];
				NSString *OldLoacation = [NSString stringWithFormat:@"MainScreenSeg%dRow%d",OldPath.section,OldPath.row];
				NSString *OldPathTitle = [[NSUserDefaults standardUserDefaults] objectForKey:OldLoacation];
				NSString *newLocation = [NSString stringWithFormat:@"MainScreenSeg%dRow%d",NewPath.section,NewPath.row];
				[updates setValue:OldPathTitle forKey:newLocation];
				if(fromIndexPath.section != 0){
					[AppDelegate configureTableViewCell:[tableView cellForRowAtIndexPath:OldPath] inTableView:tableView forIndexPath:NewPath];
				}
			}
		}
		else if (to>from){
			//moving a cell down
			for(int i = to; i > from ; i--){
				//loop through, updating each one's location
				NSIndexPath *OldPath = [NSIndexPath indexPathForRow:i inSection:fromIndexPath.section];
				NSIndexPath *NewPath = [NSIndexPath indexPathForRow:i-1 inSection:fromIndexPath.section];
				NSString *OldLoacation = [NSString stringWithFormat:@"MainScreenSeg%dRow%d",OldPath.section,OldPath.row];
				NSString *OldPathTitle = [[NSUserDefaults standardUserDefaults] objectForKey:OldLoacation];
				NSString *newLocation = [NSString stringWithFormat:@"MainScreenSeg%dRow%d",NewPath.section,NewPath.row];
				[updates setValue:OldPathTitle forKey:newLocation];
				if(fromIndexPath.section != 0){
					[AppDelegate configureTableViewCell:[tableView cellForRowAtIndexPath:OldPath] inTableView:tableView forIndexPath:NewPath];
				}
			}
		}
		
		
		for(NSString *newValue in updates){
			[[NSUserDefaults standardUserDefaults] setValue:[updates objectForKey:newValue] forKey:newValue];
		}
		
		
		/*
		 // THIS DOES NOT WORK
		 // TODO: reloadSections when the edit button is pushed, to make rearanged cells have the right color
		 
		if(fromIndexPath.section == 0){
			[tableView reloadSections:[NSIndexSet indexSetWithIndex:fromIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
		}
		 */

	}
				
}




//Support for conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}







-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return nil;
			break;
		case 1:
			return @"Links";
			break;
		default:
			return nil;
			break;
	}

}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
	if(sourceIndexPath.section != proposedDestinationIndexPath.section){
		//
		if (proposedDestinationIndexPath.section < sourceIndexPath.section){
			return [NSIndexPath indexPathForRow:0 inSection:sourceIndexPath.section];
		}
		else if (proposedDestinationIndexPath.section > sourceIndexPath.section){
			int lastRowInSection = [tableView numberOfRowsInSection:sourceIndexPath.section]-1;
			return [NSIndexPath indexPathForRow:lastRowInSection inSection:sourceIndexPath.section];
		}
			
	}
	return proposedDestinationIndexPath;
}





- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	if(1==section){
		return @"iWVU was created by Jared Crawford. It is the official open source iPhone application of West Virginia University.";
	}
	return nil;
}







- (void)dealloc {
    [super dealloc];
}







@end

