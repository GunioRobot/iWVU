//
//  DirectorySearch.m
//  iWVU
//
//  Created by Jared Crawford on 7/7/09.
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

#import "DirectorySearch.h"
#import <TapkuLibrary/TapkuLibrary.h>


@implementation DirectorySearch



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	dirSearchEngine = [[WVUDirectorySearch alloc] init];
	dirSearchEngine.delegate = self;
	[self testReachability];
}


-(void)viewDidAppear:(BOOL)animated{
	NSError *anError;
	[[GANTracker sharedTracker] trackPageview:@"/Main/Directory" withError:&anError];
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}



-(void)viewWillDisappear:(BOOL)animated{
	//cancel background threads
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)dealloc {
    [super dealloc];
}




//Search Bar



- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
	return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[searchBar resignFirstResponder];
	[theTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	
	
	
	//start a new search
	[dirSearchEngine searchWithString:searchBar.text];
}



- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
		[theTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person{
	//don't think I need to do anything here
}


//Table View


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell;
		
		NSArray *currentArray;
		if(theSearchBar.selectedScopeButtonIndex == 0){
			currentArray = dirSearchEngine.searchResults;
		}
		else if(theSearchBar.selectedScopeButtonIndex == 1){
			currentArray = dirSearchEngine.facultyResults;
		}
		else{
			currentArray = dirSearchEngine.studentResults;
		}
		ABRecordRef person = [currentArray objectAtIndex:indexPath.row];
		
		NSString *personType = (NSString *)ABRecordCopyValue(person, kABPersonNoteProperty);
		
		
		if([@"Faculty or Staff" isEqualToString:personType]){
			cell = [tableView dequeueReusableCellWithIdentifier:@"FacStaffCell"];
			if(cell==nil){
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FacStaffCell"] autorelease];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				NSString *IconPath = [[NSBundle mainBundle] bundlePath];
				cell.imageView.image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"BusinessPerson.png"]];
			}
			
		}
		else{
			cell = [tableView dequeueReusableCellWithIdentifier:@"StudentCell"];
			if(cell==nil){
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StudentCell"] autorelease];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				NSString *IconPath = [[NSBundle mainBundle] bundlePath];
				cell.imageView.image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"StudentPerson.png"]];
			}
		}
		
		
		
		
		
		
		NSString *firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
		
		NSString *LastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
		
		cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, LastName];
		
		
	
	
	
	
	
	
	
	
	return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
		if(theSearchBar.selectedScopeButtonIndex == 0){
			return [dirSearchEngine.searchResults count];
		}
		else if(theSearchBar.selectedScopeButtonIndex == 1){
			return [dirSearchEngine.facultyResults count];
		}
		else{
			return [dirSearchEngine.studentResults count];
		}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		ABUnknownPersonViewController *personViewController = [[ABUnknownPersonViewController alloc] init];
		
		NSArray *currentArray;
		if(theSearchBar.selectedScopeButtonIndex == 0){
			currentArray = dirSearchEngine.searchResults;
		}
		else if(theSearchBar.selectedScopeButtonIndex == 1){
			currentArray = dirSearchEngine.facultyResults;
		}
		else{
			currentArray = dirSearchEngine.studentResults;
		}
		ABRecordRef person = [currentArray objectAtIndex:indexPath.row];
		personViewController.displayedPerson = person;
		personViewController.unknownPersonViewDelegate = self;
		
		personViewController.allowsActions = YES;
		personViewController.allowsAddingToAddressBook = YES;
		personViewController.navigationItem.title = @"Search Results";
		[self.navigationController pushViewController:personViewController animated:YES];
}


-(void)newDirectoryDataAvailable:(WVUDirectorySearch *)searchEngine{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[theTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)directorySearchErrorOccured{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Directory Search Failed" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
	[err show];
	[err release];
}

-(void)testReachability{
	if([dirSearchEngine directoryIsReachable]){
		return;
	}
	TKEmptyView *emptyView = [[TKEmptyView alloc] initWithFrame:self.view.frame mask:[UIImage imageNamed:@"DirectoryEmptyView.png"] title:@"Directory Unavailable" subtitle:@"An internet connection is required."];
	emptyView.subtitle.numberOfLines = 2;
	emptyView.subtitle.lineBreakMode = UILineBreakModeWordWrap;
	emptyView.subtitle.font = [emptyView.subtitle.font fontWithSize:12];
	emptyView.title.font = [emptyView.title.font fontWithSize:22];
	emptyView.subtitle.clipsToBounds = NO;
	emptyView.title.clipsToBounds = NO;
	[self.view addSubview:emptyView];
	[emptyView release];
}

@end
