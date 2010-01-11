//
//  NCAAMKalDelegate.m
//  iWVU
//
//  Created by Jared Crawford on 12/21/09.
//  Copyright Jared Crawford 2009. All rights reserved.
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

#import "NCAAMKalDelegate.h"
#import "AthleticKalTableCell.h"


@implementation NCAAMKalDelegate

@synthesize viewController;

-(id)init{
	if (self = [super init]) {
		items = [[NSMutableArray alloc] init];
		NSString *URLstr = @"http://jaredcrawford.org/iWVUSampleData/MensBasketball.xml";
		//NSString *URLstr = @"http://localhost/~Jared/iWVUFiles/MensBasketball.xml";
		scoreData = [[AthleticScoreData alloc] initWithURLstr:URLstr];
		scoreData.delegate = self;
		[scoreData requestScoreData];
	}
	return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	if ([scoreData.downloadedGameData count] == 0) { 
		UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Warning"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		if (indexPath.row == 1) {
			cell.textLabel.numberOfLines = 2;
			cell.textLabel.text = @"An internet connection is required\nto download schedule data.";
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			cell.textLabel.font = [cell.textLabel.font fontWithSize:14];
			cell.textLabel.textColor = [UIColor grayColor];
		}
		else{
			cell.textLabel.text = @"";
		}
		return cell;
	}
	NSDictionary *gameDict = [items objectAtIndex:indexPath.row];
	AthleticKalTableCell *cell=[[AthleticKalTableCell alloc] initWithDict:gameDict andSportOrNil:@"Men's Basketball"];
	[cell autorelease];
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if ([scoreData.downloadedGameData count] == 0) {
		return 2;
	}
	return [items count];
}

- (void)loadDate:(NSDate *)date{
	[items removeAllObjects];
	for (NSDictionary *dict in scoreData.downloadedGameData) {
		NSDate *gameTime = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"startDateTime"] doubleValue]];
		double secondsBetween = [gameTime timeIntervalSinceDate:date];
		if ((secondsBetween>=0)&&(secondsBetween<86400)) {//in the same calendar day
			[items addObject:dict];
		}
	}
}

- (BOOL)hasDetailsForDate:(NSDate *)date{
	for (NSDictionary *dict in scoreData.downloadedGameData) {
		NSDate *gameTime = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"startDateTime"] doubleValue]];
		double secondsBetween = [gameTime timeIntervalSinceDate:date];
		if ((secondsBetween>=0)&&(secondsBetween<86400)) {//in the same calendar day
			return YES;
		}
	}
	return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	NSDictionary *dict = [items objectAtIndex:indexPath.row];
	AthleticScoresViewController *aViewController = [[AthleticScoresViewController alloc] initWithDictionary:dict];
	iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	[AppDelegate.navigationController pushViewController:aViewController animated:YES];
}

-(void)newScoreDataAvailable{
	[viewController refresh];
}

-(NSString *)sportName{
	return @"NCAAM";
}

- (void)dealloc{
	[items release];
	[scoreData release];
	[super dealloc];
}

@end
