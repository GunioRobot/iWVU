//
//  BuildingList.m
//  iWVU
//
//  Created by Jared Crawford on 6/13/09.
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

#import "BuildingList.h"
#import "BuildingLocationController.h"
#import "iWVUAppDelegate.h"





@implementation BuildingList

@synthesize delegate;
@synthesize allowsCurrentLocation;
@synthesize allowsAllBuildings;
@synthesize style;


- (void)viewDidLoad {
    [super viewDidLoad];

	theSearchBar.tintColor = [UIColor colorWithRed:0 green:.2 blue:.4 alpha:1];

	
	
	downtownBuildings = [[NSArray alloc] initWithObjects:
						 
						 
						 @"Armstrong Hall",
						 @"Arnold Apartments",
						 @"Arnold Hall",
						 @"Boreman Hall North",
						 @"Boreman Hall South",
						 @"Boreman Residential Faculty",
						 @"Brooks Hall",
						 @"Business & Economics Building (BNE)",
						 @"Chemistry Research Labratory",
						 @"Chales C. Wise, Jr. Library",
						 @"Chitwood Hall",
						 @"Clark Hall",
						 @"Colson Hall",
						 @"Dadisman Hall",
						 @"Downtown Bookstore",
						 @"Downtown Library",
						 @"Downtown PRT Station",
						 @"Eisland Hall",
						 @"Elizabeth Moore Hall (E. Moore)",
						 @"Hodges Hall",
						 @"Honors Hall",
						 @"International House",
						 @"Knapp Hall",
						 @"Life Sciences Building (LSB)",
						 @"Martin Hall",
						 @"Ming Hsieh Hall",
						 @"Mountainlair",
						 @"Oglebay Hall",
						 @"One Waterfront Place",
						 @"Puriton House",
						 @"Spruce House",
						 @"Stalnaker Hall",
						 @"Stansbury Hall",
						 @"Stewart Hall",
						 @"Student Services Center",
						 @"Summit",
						 @"Walnut PRT Station",
						 @"White Hall",
						 @"Woodburn Hall",
						 
						 
						 nil];
	
	
	
	evansdaleBuildings = [[NSArray alloc] initWithObjects:
						  
						  @"Aerodynamics Laboratory",
						  @"Agricultural Sciences Annex",
						  @"Agricultural Sciences Building",
						  @"Allen Hall",
						  @"Animal Science Farm",
						  @"Bennett Tower",
						  @"Braxton Tower",
						  @"Brooke Tower",
						  @"Cary Gymnastics Center",
						  @"Coliseum",
						  @"Creative Arts Center",
						  @"Crime Scene Houses",
						  @"Dick Dlesk Soccer Stadium",
						  @"Engineering PRT Station",
						  @"Engineering Research Building (ERB)",
						  @"Engineering Sciences Building (ESB)",
						  @"ERC RFL Annex Office Building",
						  @"Evansdale Library",
						  @"Evansdale Resedential Complex",
						  @"Greenhouse",
						  @"Hawley Baseball Field",
						  @"Law Center",
						  @"Lincoln Hall",
						  @"Lyon Tower",
						  @"Mineral Resources Building",
						  @"Natatorium Shell",
						  @"National Research Center",
						  @"North Street House",
						  @"Nursery School",
						  @"Percival Hall",
						  @"Physical Plant",
						  @"Pierpont Apartments",
						  @"South Agricultural Sciences",
						  @"Student Recreation Center",
						  @"Track and Field",
						  @"Towers",
						  @"Towers PRT Station",
						  @"University Services Center",
						  
						  nil];
	
	
	
	
	
	
	
	
	HSCBuildings = [[NSArray alloc] initWithObjects:
					
					@"Caperton Indoor Facility",
					@"Chestnut Ridge Hospital",
					@"Chestnut Ridge Prof Building",
					@"Chestnut Ridge Research Building",
					@"Erickson Alumni Center",
					@"Fieldcrest Hall",
					@"Football Stadium",
					@"Health Sciences Addition",
					@"Health Sciences North",
					@"Health Sciences South",
					@"Medical Center Apartments",
					@"Medical PRT Station",
					@"Milan Puskar Center",
					@"NIOSH Building",
					@"Robert C. Byrd Health Sciences Center",
					@"Ruby Memorial Hospital",
					
					nil];
	
	NSMutableArray *sortedBuildings = [NSMutableArray array];
	for(NSString *build in evansdaleBuildings){
		[sortedBuildings addObject:build];
	}
	for(NSString *build in downtownBuildings){
		[sortedBuildings addObject:build];
	}
	for(NSString *build in HSCBuildings){
		[sortedBuildings addObject:build];
	}
	allBuildings=[[sortedBuildings sortedArrayUsingSelector:@selector(compare:)] retain];
	
	
	searchResultsBuildings = [[NSArray array] retain];
	
}


- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
	if ((searchBar.text != nil) && (![searchBar.text isEqualToString:@""])) {
		[self searchBar:searchBar textDidChange:searchBar.text];
	}
	[theTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
	[theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0	inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
	//do a search
	//put results in searchResultsBuildings NSArray
	
	
	if ((theSearchBar.text == nil) || ([theSearchBar.text isEqualToString:@""])) {
		[theSearchBar setShowsCancelButton:YES animated:YES];
	}
	else {
		[theSearchBar setShowsCancelButton:NO animated:YES];
	}

	
	
	
	[searchResultsBuildings release];
	NSMutableArray *buildingsWhichMatch = [NSMutableArray array];
	
	NSArray *selectedSortType;
	NSString *scopeName = [[searchBar scopeButtonTitles] objectAtIndex:searchBar.selectedScopeButtonIndex];
	if ([scopeName isEqualToString:@"Downtown"]) {
		selectedSortType = downtownBuildings;
	}
	else if ([scopeName isEqualToString:@"Evansdale"]) {
		selectedSortType = evansdaleBuildings;
	}
	else if ([scopeName isEqualToString:@"HSC"]) {
		selectedSortType = HSCBuildings;
	}
	else {
		selectedSortType = allBuildings;
	}
	
	
	for(NSString *building in selectedSortType){
		NSString *lowercaseBuilding = [building lowercaseString];
		NSString *lowercaseSearch = [theSearchBar.text lowercaseString];
		NSRange range = [lowercaseBuilding rangeOfString:lowercaseSearch];
		if (range.location != NSNotFound) {
			[buildingsWhichMatch addObject:building];
		}
	}
	
	searchResultsBuildings = [[NSArray arrayWithArray:buildingsWhichMatch] retain];
	
	[theTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
	[theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0	inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}



- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
	[searchBar setShowsCancelButton:YES animated:YES];
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
		return 1;
	}
	else if(section == 1){
		if ((theSearchBar.text == nil) || ([theSearchBar.text isEqualToString:@""])) {
			NSString *selectedSort = [[theSearchBar scopeButtonTitles] objectAtIndex:theSearchBar.selectedScopeButtonIndex];
			if([@"All" isEqualToString:selectedSort]){
				return [allBuildings count];
			}
			else if([@"Downtown" isEqualToString:selectedSort]){
				return [downtownBuildings count];
			}
			else if([@"Evansdale" isEqualToString:selectedSort]){
				return [evansdaleBuildings count];
			}
			else if([@"HSC" isEqualToString:selectedSort]){
				return [HSCBuildings count];
			}
		}
		else{
			return [searchResultsBuildings count];
		}
	}
	
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	iWVUAppDelegate *AppDelegate = [[UIApplication sharedApplication] delegate];
	[AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
	
    // Set up the cell...
	
	NSString *mainLabel;
	
	
	
	if(indexPath.section == 0){
			mainLabel = @"All Buildings";
	}
	else if (indexPath.section == 1){
			
		if ((theSearchBar.text == nil) || ([theSearchBar.text isEqualToString:@""])) {
			NSString *selectedSort = [[theSearchBar scopeButtonTitles] objectAtIndex:theSearchBar.selectedScopeButtonIndex];
			if([@"All" isEqualToString:selectedSort]){
				mainLabel = [allBuildings objectAtIndex:indexPath.row];
			}
			else if([@"Downtown" isEqualToString:selectedSort]){
				//
				mainLabel = [downtownBuildings objectAtIndex:indexPath.row];
			}
			else if([@"Evansdale" isEqualToString:selectedSort]){
				//
				mainLabel = [evansdaleBuildings objectAtIndex:indexPath.row];
			}
			else if([@"HSC" isEqualToString:selectedSort]){
				//
				mainLabel = [HSCBuildings objectAtIndex:indexPath.row];
			}
		}
		else {
			mainLabel = [searchResultsBuildings objectAtIndex:indexPath.row];
		}

	}
	
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.text = mainLabel;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	iWVUAppDelegate *AppDelegate = [[UIApplication sharedApplication] delegate];
	
	
	
	
	
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	BuildingLocationController *theBuildingView = [[BuildingLocationController alloc] initWithNibName:@"BuildingLocation" bundle:nil];
	NSString *buildingName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
	theBuildingView.buildingName = buildingName;
	theBuildingView.navigationItem.title = buildingName;
	[AppDelegate.navigationController pushViewController:theBuildingView animated:YES];
	[theBuildingView release];

	
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
    
	[downtownBuildings release];
	[evansdaleBuildings release];
	[HSCBuildings release];
	[searchResultsBuildings release];
	
	
	[super dealloc];
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if (section == 1){
		NSString *selectedSort = [[theSearchBar scopeButtonTitles] objectAtIndex:theSearchBar.selectedScopeButtonIndex];
		if([@"All" isEqualToString:selectedSort]){
			return @"All WVU Buildings";
		}
		else if([@"Downtown" isEqualToString:selectedSort]){
			return @"Downtown Campus Buildings";
		}
		else if([@"Evansdale" isEqualToString:selectedSort]){
			return @"Evansdale Campus Buildings";
		}
		else if([@"HSC" isEqualToString:selectedSort]){
			return @"Health Sciences Campus Buildings";
		}
	}
	return nil;
}





@end

