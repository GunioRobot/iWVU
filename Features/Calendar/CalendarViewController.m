//
//  CalendarViewController.m
//  iWVU
//
//  Created by Jared Crawford on 3/5/10.
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

#import "CalendarViewController.h"
#import "CJSONDeserializer.h"
#import "NSString+MD5.h"
#import "NSDate+Helper.h"



@implementation CalendarViewController

@synthesize calendarKey;

////////Calendar Data Values//////
//startTime 
//title 
//endTime
////////Optional//////////////////
//contactPhone 
//contactEmail
//location
//contactName 
//description
//eventLink
//////////////////////////////////

-(void)viewDidLoad{
	[super viewDidLoad];
	
	downloadThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadCalendarData) object:nil];
	[downloadThread start];

}


-(void)viewWillAppear:(BOOL)animated{
	self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	
	if (self.monthView.frame.size.width != self.view.frame.size.width) {
		self.monthView.frame = CGRectMake((self.view.frame.size.width - 320)/2.0, self.monthView.frame.origin.y, self.monthView.frame.size.width, self.monthView.frame.size.height);
	}
	self.tableView.frame = CGRectMake(self.monthView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height );
}

-(void)viewWillDisappear:(BOOL)animated{
	[downloadThread cancel];
	[downloadThread release];
	downloadThread = nil;
}

-(void)reloadViews{
	[self.monthView reload];
	[self.monthView selectDate:[NSDate date]];
}

-(void)displayErrorScreen{
	TKEmptyView *emptyView = [[TKEmptyView alloc] initWithFrame:self.view.frame mask:[UIImage imageNamed:@"CalendarEmptyView.png"] title:@"Calendar Unavailable" subtitle:@"An internet connection is required."];
	
	[self.view addSubview:emptyView];
	[emptyView release];
}

-(void)downloadCalendarData{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	if(calendarKey){
		NSString *calendarDataURL = [NSString stringWithFormat:@"http://m.wvu.edu/calendar/json/index.php?id=%@",calendarKey];
		NSError *err;
		NSLog(@"%@", calendarDataURL);
		NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:calendarDataURL]];
		if(![[NSThread currentThread] isCancelled]){
			calendarItems = [[[CJSONDeserializer deserializer] deserializeAsArray:jsonData error:&err] retain];
			if(calendarItems){
				[self performSelectorOnMainThread:@selector(reloadViews) withObject:nil waitUntilDone:NO];
			}
			else{
				[self performSelectorOnMainThread:@selector(displayErrorScreen) withObject:nil waitUntilDone:NO];
			}
		}
		[downloadThread release];
		downloadThread = nil;
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[pool release];
}

- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate{
	NSDate *loopDate = startDate;
    NSMutableArray *returnArray = [NSMutableArray array];
    while([loopDate compare:lastDate] !=  NSOrderedDescending){
        BOOL foundEventOnThisDate = NO;
        if([[self eventsOnDate:loopDate] count] > 0){
            foundEventOnThisDate = YES;
        }
        [returnArray addObject:[NSNumber numberWithBool:foundEventOnThisDate]];
        loopDate = [self oneDayFrom:loopDate];
    }
    return [NSArray arrayWithArray:returnArray];
}



- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date{
	[eventsForCurrentDay release];
	eventsForCurrentDay = [[self eventsOnDate:date] retain];
	[tableView reloadData];
}


-(NSArray *)eventsOnDate:(NSDate *)date{
	NSMutableArray *events = [NSMutableArray array];
    NSDate *oneDayFromDate = [self oneDayFrom:date];
	for (NSDictionary *dict in calendarItems) {
		NSDate *eventTime = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"startTime"] doubleValue]];
		if (([eventTime timeIntervalSinceDate:date]>=0)&&([eventTime timeIntervalSinceDate:oneDayFromDate]<0)) {//in the same calendar day
			[events addObject:dict];
		}
	}
    
    return [NSArray arrayWithArray:events];
}

-(NSDate *)oneDayFrom:(NSDate *)date{
    //using DateComponents to get the next calendar day to avoid DST bug
    NSDateComponents *oneDay = [[NSDateComponents alloc] init];
    [oneDay setDay:1];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *oneDayFromDate = [gregorian dateByAddingComponents:oneDay toDate:date options:0];
    [oneDay release];
    [gregorian release];
    return oneDayFromDate;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	if((calendarItems != nil) && ([eventsForCurrentDay count] == 0)){
		return 4;
	}
	
	return [eventsForCurrentDay count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

	UITableViewCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:@"CalendarDay"];
	if(cell==nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CalendarDay"] autorelease];
	} 
	
	if([eventsForCurrentDay count]>0){
		NSDictionary *event = [eventsForCurrentDay objectAtIndex:indexPath.row];
		cell.textLabel.text = [[event valueForKey:@"title"] stringByDecodingXMLEntities];
		cell.textLabel.font = [cell.textLabel.font fontWithSize:12];
		NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:[[event valueForKey:@"startTime"] floatValue]];
		cell.detailTextLabel.text = [[NSDate stringFromDate:startTime withFormat:@"h:mm a"] uppercaseString];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.textColor = [UIColor blackColor];
		cell.detailTextLabel.textColor = [UIColor grayColor];
	}
	else{
		cell.textLabel.text = @"";
		cell.detailTextLabel.text = @"";
		cell.accessoryType = UITableViewCellAccessoryNone;
		if(indexPath.row == 3){
			cell.textLabel.textColor = [UIColor lightGrayColor];
			cell.textLabel.text = @"No events for this date.";
		}
	}
	
	return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSDictionary *dict = [eventsForCurrentDay objectAtIndex:indexPath.row];
	
	UIViewController *viewController = [EventViewManager loadEventViewWithDictionary:dict andDelegate:self];
	[self.navigationController pushViewController:viewController animated:YES];
	
}




- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue{
	return YES;
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
