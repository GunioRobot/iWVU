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





@implementation BuildingList

@synthesize delegate;


- (void)viewDidLoad {
    [super viewDidLoad];

	theSearchBar.tintColor = [UIColor WVUBlueColor];

	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	[SQLite initialize];
	buildingData = [[SQLite query:@"SELECT * FROM \"Buildings\" WHERE \"type\" NOT IN (\"Parking Lot\", \"Public Parking\")"] retain];
	
	NSMutableArray *sortedBuildings = [NSMutableArray array];
	NSMutableArray *tempDowntown = [NSMutableArray array];
	NSMutableArray *tempEvansdale = [NSMutableArray array];
	NSMutableArray *tempHSC = [NSMutableArray array];
	NSMutableDictionary *tempBuildingCodes = [NSMutableDictionary dictionary];

	
	
	
	for(NSDictionary *dict in buildingData.rows){
		NSString *buildingName = [dict objectForKey:@"name"];
		if(buildingName != nil){
			
			//add all buildings to one list
			[sortedBuildings addObject:buildingName];
			
			//sort by campus for the rest
			NSString *campusName = [dict objectForKey:@"campus"];
			if([@"Downtown" isEqualToString:campusName]){
				[tempDowntown addObject:buildingName];
			}
			else if([@"Evansdale" isEqualToString:campusName]){
				[tempEvansdale addObject:buildingName];
			}
			else{
				[tempHSC addObject:buildingName];
			}
			
			//store the building codes in a dictionary for all buildings that have one
			NSString *code = [dict objectForKey:@"code"];
			if(code){
				[tempBuildingCodes setValue:code forKey:buildingName];
			}
		}
	}
	
	
	
	allBuildings=[[sortedBuildings sortedArrayUsingSelector:@selector(compare:)] retain];
	downtownBuildings=[[tempDowntown sortedArrayUsingSelector:@selector(compare:)] retain];
	evansdaleBuildings=[[tempEvansdale sortedArrayUsingSelector:@selector(compare:)] retain];
	HSCBuildings=[[tempHSC sortedArrayUsingSelector:@selector(compare:)] retain];
	buildingCodes=[[NSDictionary dictionaryWithDictionary:tempBuildingCodes] retain];
	
	
	searchResultsBuildings = [[NSArray array] retain];
	
}



-(void)viewDidUnload{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)keyboardWillShow:(NSNotification *)note{
	//adjust theTableView content offset to compensate for keyboard
	
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    float keyboardHeight = keyboardBounds.size.height;
	UIEdgeInsets inset = theTableView.contentInset;
	inset.bottom = keyboardHeight;
	
	theTableView.contentInset = inset;

	
}

-(void)keyboardWillHide:(NSNotification *)note{
	//adjust theTableView content offset to compensate for keyboard
	
	UIEdgeInsets inset = theTableView.contentInset;
	inset.bottom = 0;
	
	theTableView.contentInset = inset;
	
	
}


-(void)scrollToBestPosition{
	if([theTableView numberOfRowsInSection:1] != 0){
		[theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0	inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
	else if ([theTableView numberOfRowsInSection:0] != 0) {
		[theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0	inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
	if ((searchBar.text != nil) && (![searchBar.text isEqualToString:@""])) {
		[self searchBar:searchBar textDidChange:searchBar.text];
	}
	[theTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
	[self scrollToBestPosition];
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
	//do a search
	//put results in searchResultsBuildings NSArray
	
	/*
	if ((theSearchBar.text == nil) || ([theSearchBar.text isEqualToString:@""])) {
		[theSearchBar setShowsCancelButton:YES animated:YES];
	}
	else {
		[theSearchBar setShowsCancelButton:NO animated:YES];
	}

	*/
	
	
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
		
		NSString *aCode = [[buildingCodes objectForKey:building] lowercaseString];
		NSString *first3OfACode = @"someGarbage";
		if ([aCode length]>3) {
			first3OfACode = [aCode substringToIndex:3];
		}
		if (([aCode isEqualToString:lowercaseSearch])||([lowercaseSearch isEqualToString:first3OfACode])) {
			[buildingsWhichMatch removeAllObjects];
			[buildingsWhichMatch addObject:building];
			break;
		}
		else {
			NSRange range = [lowercaseBuilding rangeOfString:lowercaseSearch];
			if (range.location != NSNotFound) {
				[buildingsWhichMatch addObject:building];
			}
		}

	}
	
	searchResultsBuildings = [[NSArray arrayWithArray:buildingsWhichMatch] retain];
	
	[theTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
	[self scrollToBestPosition];
}



- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
	[searchBar setText:@""];
	[searchBar setShowsCancelButton:NO animated:YES];
	[searchBar.delegate searchBar:searchBar textDidChange:searchBar.text];
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
		
		BOOL allowsAllBuildings = [delegate allowsAllBuildings];
		BOOL allowsCurrentLocation = [delegate allowsCurrentLocation];
		
		if (allowsAllBuildings && allowsCurrentLocation) {
			return 2;
		}
		else if(allowsAllBuildings || allowsCurrentLocation){
			return 1;
		}
		return 0;
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
    
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
    // Set up the cell...
	
	NSString *mainLabel = @"";
	
	
	
	if(indexPath.section == 0){
		BOOL allowsAllBuildings = [delegate allowsAllBuildings];
		BOOL allowsCurrentLocation = [delegate allowsCurrentLocation];
		
		if (allowsAllBuildings && allowsCurrentLocation) {
			if (indexPath.row == 0) {
				mainLabel = @"All Buildings";
			}
			else if(indexPath.row == 1){
				mainLabel = @"Current Location";
			}
		}
		else if(allowsAllBuildings && !allowsCurrentLocation){
			mainLabel = @"All Buildings";
		}
		else if(!allowsAllBuildings && allowsCurrentLocation){
			mainLabel = @"Current Location";
		}
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
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 1) {
		selectedBuilding = [[tableView cellForRowAtIndexPath:indexPath].textLabel.text retain];
		[delegate BuildingList:self didFinishWithSelectionType:BuildingSelectionTypeBuilding];
	}
	else if(indexPath.section == 0){
		[selectedBuilding release];
		selectedBuilding = nil;
		NSString *selection = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
		if ([selection isEqualToString:@"All Buildings"]) {
			[delegate BuildingList:self didFinishWithSelectionType:BuildingSelectionTypeAllBuildings];
		}
		if ([selection isEqualToString:@"Current Location"]) {
			[delegate BuildingList:self didFinishWithSelectionType:BuildingSelectionTypeCurrentLocation];
		}
	}

	
}


- (void)dealloc {
    
	[downtownBuildings release];
	[evansdaleBuildings release];
	[HSCBuildings release];
	[searchResultsBuildings release];
	[selectedBuilding release];
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



-(id)initWithDelegate:(id<BuildingListDelegate>)aDelegate{
	[self initWithNibName:@"BuildingList" bundle:nil];
	self.delegate = aDelegate;
	return self;
}

-(NSString *) selectedBuildingName{
	return selectedBuilding;
}

-(CLLocationCoordinate2D) selectedBuildingCoordinates{
	
	CLLocationCoordinate2D aCoord;
	aCoord.longitude = 0;
	aCoord.latitude = 0;
	
	if(selectedBuilding == nil){
		return aCoord;
	}
	
	for(NSDictionary *dict in buildingData.rows){
		if([[dict objectForKey:@"name"] isEqualToString:selectedBuilding]){
			aCoord.longitude = [[dict objectForKey:@"longitude"] floatValue];
			aCoord.latitude = [[dict objectForKey:@"latitude"] floatValue];
		}
	}
	
	return aCoord;
	
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	//these are the default's, but I'm going to explicitly define them, just to be safe
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		if (interfaceOrientation == UIInterfaceOrientationPortrait) {
			return YES;
		}
		return NO;
	}
	return YES;
}


@end

