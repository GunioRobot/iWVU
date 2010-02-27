//
//  PRTinfo.m
//  iWVU
//
//  Created by Jared Crawford on 6/15/09.
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

#import "PRTinfo.h"
#import "BuildingLocationController.h"
#import "NSDate+Helper.h"

#define PRT_STATUS_FEED 0 //-1 is off, 0 is on

@implementation PRTinfo




-(void)viewDidAppear:(BOOL)animated{
	NSError *anError;
	[[GANTracker sharedTracker] trackPageview:@"/Main/PRT" withError:&anError];
}



/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	#if PRT_STATUS_FEED != -1
	status = [@"Loading..." retain];
	timestamp = [@"" retain];
	statusThread = [[NSThread alloc] initWithTarget:self selector:@selector(getCurrentStatus) object:nil];
	[statusThread start];
	#endif
	PRTIsDown = NO;
	
	PRTStops = [[NSArray alloc] initWithObjects:
	
				@"Walnut",
				@"Downtown",
				// @"Maintenance",
				@"Engineering",
				@"Towers",
				@"Medical",
				
				nil];
	
	
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[statusThread cancel];
	[statusThread release];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6+PRT_STATUS_FEED;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0+PRT_STATUS_FEED:
			return 1;
			break;
		case 1+PRT_STATUS_FEED:
			return 1;
			break;
		case 2+PRT_STATUS_FEED:
			return [PRTStops count];
			break;
		case 3+PRT_STATUS_FEED:
			return 4;
			break;
		case 4+PRT_STATUS_FEED:
			return 4;
			break;
		case 5+PRT_STATUS_FEED:
			return 2;
			break;
		default:
			return 0;
			break;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	iWVUAppDelegate *AppDelegate = [[UIApplication sharedApplication] delegate];
	cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
	NSString *mainText = @"";
	NSString *subText = @"";
	
	switch (indexPath.section) {
		case 0+PRT_STATUS_FEED:
			mainText = status;
			cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
			cell.textLabel.numberOfLines = 0;//unlimited
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			break;
		case 1+PRT_STATUS_FEED:
			mainText = @"All Stations";
			break;
		case 2+PRT_STATUS_FEED:
			mainText =  [PRTStops objectAtIndex:indexPath.row];
			break;
		case 3+PRT_STATUS_FEED:
			mainText = @"";
			//push Hours subview
			//maybe avoid reuse
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			if(indexPath.row == 0){
				subText = @"6:30 AM - 10:15 PM";
				mainText = @"Weekdays";
			}
			else if (indexPath.row == 1){
				subText = @"9:30 AM - 5:00 PM";
				mainText = @"Saturday";
			}
			else if(indexPath.row == 2){
				subText = @"Closed";
				mainText = @"Sunday";
			}
			else{
				subText = @"Closed";
				mainText = @"University Holidays";
			}
			
			
			
			break;
		case 4+PRT_STATUS_FEED:
			//
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			if(indexPath.row == 0){
				subText = @"6:30 AM - 6:15 PM";
				mainText = @"Weekdays";
			}
			else if (indexPath.row == 1){
				subText = @"9:30 AM - 5:00 PM";
				mainText = @"Saturday";
			}
			else if(indexPath.row == 2){
				subText = @"Closed";
				mainText = @"Sunday";
			}
			else{
				subText = @"Closed";
				mainText = @"University Holidays";
			}
			break;
		case 5+PRT_STATUS_FEED:
			if(indexPath.row==0){
				mainText = @"Maintenance";
				subText = @"(304) 293-5011";
			}
			else{
				mainText = @"PRT Website";
			}
			break;
		default:
			return 0;
			break;
	}
	
	
	cell.textLabel.text = mainText;
	cell.detailTextLabel.text = subText;
	
	
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	iWVUAppDelegate *AppDelegate = [[UIApplication sharedApplication] delegate];
	
	
	if((indexPath.section <= 2+PRT_STATUS_FEED) && (indexPath.section >= 1+PRT_STATUS_FEED)){
		
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		BuildingLocationController *theBuildingView = [[BuildingLocationController alloc] initWithNibName:@"BuildingLocation" bundle:nil];
		NSString *buildingName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
		if(![buildingName isEqualToString:@"All Stations"]){
			buildingName = [buildingName stringByAppendingString:@" PRT Station"];
		}
		theBuildingView.buildingName = buildingName;
		theBuildingView.navigationItem.title = buildingName;
		[self.navigationController pushViewController:theBuildingView animated:YES];
		[theBuildingView release];
	}
	
	if(indexPath.section == 5+PRT_STATUS_FEED){
		if(indexPath.row==0){
			NSString *phoneNum = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;			
			[AppDelegate callPhoneNumber:phoneNum];
		}
		else if(indexPath.row == 1){
			OPENURL(@"http://transportation.wvu.edu/prt");
		}
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

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if((indexPath.section == 2) && (indexPath.row <= 1)){
		return 270;
	}
	return 44;
}
 */








-(void)getCurrentStatus{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	NSURL *xmlURL = [NSURL URLWithString:@"http://prtstatus.sitespace.wvu.edu/cache.php?mobi=true"];
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	xmlParser.delegate = self;
	[xmlParser parse];
	[pool release];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if (section == 0+PRT_STATUS_FEED) {
		return @"Current PRT Status";
	}
	else if(section == 1+PRT_STATUS_FEED){
		return @"Maps";
	}
	else if(section == 3+PRT_STATUS_FEED){
		return @"Fall and Spring Semester Schedule";
	}
	else if(section == 4+PRT_STATUS_FEED){
		return @"Summer Schedule";
	}
	return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	if ((section == 0+PRT_STATUS_FEED) && PRTIsDown) {
		/*
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
		NSDate *dateFromString;
		dateFromString = [dateFormatter dateFromString:timestamp];
		 */
		
		NSDate *dateFromString = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
		
		NSString *theTimeAgo = [dateFromString stringDaysAgo];
		if ([theTimeAgo isEqualToString:@"Today"]) {
			NSString *todaysTime = [NSString stringWithFormat:@"Today at %@", [NSDate stringForDisplayFromDate:dateFromString]];
			theTimeAgo = todaysTime ;
		}
		
		return [NSString stringWithFormat:@"Last Updated:\n%@",theTimeAgo];
	}
	return nil;
}


- (void)dealloc {
    [super dealloc];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict{
	[currentXMLElement release];
	currentXMLElement = [elementName retain];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	
	if ([currentXMLElement isEqualToString:@"message"]) {
		if ([status isEqualToString:@"Loading..."]) {
			status = string;
			[status retain];
		}
		else {
			NSString *tempStatus = [status stringByAppendingString:string];
			[status release];
			status = tempStatus;
			[status retain];
		}

	}
	else if ([currentXMLElement isEqualToString:@"timestamp"]) {
		if ([timestamp isEqualToString:@""]) {
			timestamp = string;
			[timestamp retain];
		}
		else {
			NSString *TempTimestamp = [timestamp stringByAppendingString:string];
			[timestamp release];
			timestamp = TempTimestamp;
			[timestamp retain];
		}
		
	}
	else if ([currentXMLElement isEqualToString:@"status"]) {
		if ([string intValue] == 1) {
			PRTIsDown = NO;
		}
		else {
			PRTIsDown = YES;
		}
	}

	
}


- (void)parserDidStartDocument:(NSXMLParser *)parser{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self performSelectorOnMainThread:@selector(reloadStatusFeed) withObject:nil waitUntilDone:NO];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
	status = [@"Status Unavailable." retain];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self performSelectorOnMainThread:@selector(reloadStatusFeed) withObject:nil waitUntilDone:NO];
}

-(void)reloadStatusFeed{
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.section == 0) {
		UIFont *aFont = [UIFont systemFontOfSize:17];
		CGSize theSize = [status sizeWithFont:aFont constrainedToSize:CGSizeMake(300.0, 1000.0) lineBreakMode:UILineBreakModeTailTruncation];
		CGFloat cellHeight =  theSize.height + 30;
		if (cellHeight<45) {
			return 45;
		}
		return cellHeight;
	}
	return 45;
}



@end

