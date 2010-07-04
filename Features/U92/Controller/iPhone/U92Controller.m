//
//  U92Controller.m
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



#import "U92Controller.h"
#import "BuildingLocationController.h"
#import "TwitterTableView.h"
#import <TapkuLibrary/TapkuLibrary.h>






@implementation U92Controller



- (void)viewDidLoad {
    [super viewDidLoad];
	theTableView.backgroundColor = [UIColor viewBackgroundColor];
	
	showLabel.text = @"Loading...";
	showLabel.font = [UIFont systemFontOfSize:25];
	showLabel.textAlignment = UITextAlignmentLeft;
	showLabel.contentMode = UIViewContentModeCenter;
	showLabel.backgroundColor = [UIColor clearColor];
	showLabel.textColor = [UIColor grayColor];
	showLabel.spotlightColor = [UIColor whiteColor];
	
	[showLabel startAnimating];
	
    detailsEngine = [[RadioDetails alloc] init];
	[detailsEngine addObserver:self forKeyPath:@"currentShow" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)layoutButtons{
	
	CGSize textSize = [showLabel.text sizeWithFont:showLabel.font];
	
	float labelHeight = textSize.height;
	float labelWidth = textSize.width;
	float buttonWidth = playPauseButton.frame.size.width;
	float buttonHeight = playPauseButton.frame.size.height;
	
	float centerOfScreen = self.view.frame.size.width / 2.0;
	float xOfButton = centerOfScreen - ((labelWidth + buttonWidth)/2.0);
	float xOfLabel = xOfButton + buttonWidth;
	
	float yOfButton = playPauseButton.frame.origin.y;
	float centerOfButton = yOfButton + (buttonHeight/2.0);
	float yOfLabel = centerOfButton - (labelHeight/2.0);
	
	showLabel.frame = CGRectMake(xOfLabel, yOfLabel-2, labelWidth, labelHeight);
	playPauseButton.frame = CGRectMake(xOfButton, yOfButton, buttonWidth, buttonHeight);
	
	[showLabel newMask];
	[showLabel startAnimating];
	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqual:@"currentShow"]) {
		NSString *currentShow = ((RadioDetails *)object).currentShow;
		if (![currentShow isEqualToString:NO_U92_ERROR_STR]) {
			showLabel.text = currentShow;
			[self layoutButtons];
		}
		else {
			TKEmptyView *emptyView = [[TKEmptyView alloc] initWithFrame:self.view.frame mask:[UIImage imageNamed:@"TwitterEmptyView.png"] title:@"U92 Unavailable" subtitle:@"An internet connection is required"];
			emptyView.subtitle.numberOfLines = 2;
			emptyView.subtitle.lineBreakMode = UILineBreakModeWordWrap;
			emptyView.subtitle.font = [emptyView.subtitle.font fontWithSize:12];
			emptyView.title.font = [emptyView.title.font fontWithSize:22];
			emptyView.subtitle.clipsToBounds = NO;
			emptyView.title.clipsToBounds = NO;
			[self.view addSubview:emptyView];
			[emptyView release];
		}

	}
}




-(IBAction)playPauseButtonPressed{
	if ([[UIApplication sharedApplication] isStreamingRadio]) {
		[playPauseButton setImage:[UIImage imageNamed:@"PlayButton"] forState:UIControlStateNormal];
	}
	else {
		[playPauseButton setImage:[UIImage imageNamed:@"PauseButton"] forState:UIControlStateNormal];;
	}
	[[UIApplication sharedApplication] playPauseButtonPressed];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 2;
			break;
		case 2:
			return 7;
			break;
	}
	return 0;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
	cell.backgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}





-(IBAction)viewPickerChanged:(UISegmentedControl *)sender{
	NSString *selectedTitle = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
	CGRect newRect = CGRectMake(0, 0, middleView.frame.size.width, middleView.frame.size.height);
	UIView *tempNewMiddleView;
	
	if ([@"Twitter" isEqualToString:selectedTitle]) {
		tempNewMiddleView = [[TwitterTableView alloc] initWithFrame:newRect];
		((TwitterTableView *)tempNewMiddleView).twitterUserName = @"U92WVU";
	}
	else if([@"Website" isEqualToString:selectedTitle]){
		UIWebView *webView = [[UIWebView alloc] initWithFrame:newRect];
		webView.scalesPageToFit = YES;
		NSURL *url = [NSURL URLWithString:@"http://u92.wvu.edu"];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		[webView loadRequest:request];
		
		tempNewMiddleView = webView;
	}
	else if([@"Email" isEqualToString:selectedTitle]){
		iWVUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
		[appDelegate composeEmailTo:@"u92@mail.wvu.edu" withSubject:nil andBody:nil];
		TKEmptyView *emptyView = [[TKEmptyView alloc] initWithFrame:newRect mask:[UIImage imageNamed:@"TwitterEmptyView.png"] title:@"Email U92" subtitle:@""];
		emptyView.subtitle.numberOfLines = 2;
		emptyView.subtitle.lineBreakMode = UILineBreakModeWordWrap;
		emptyView.subtitle.font = [emptyView.subtitle.font fontWithSize:12];
		emptyView.title.font = [emptyView.title.font fontWithSize:22];
		emptyView.subtitle.clipsToBounds = NO;
		emptyView.title.clipsToBounds = NO;
		tempNewMiddleView = emptyView;
	}
	else if([@"Phone" isEqualToString:selectedTitle]){
		iWVUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
		[appDelegate callPhoneNumber:@"(304) 293-3329"];
		TKEmptyView *emptyView = [[TKEmptyView alloc] initWithFrame:newRect mask:[UIImage imageNamed:@"TwitterEmptyView.png"] title:@"Call U92" subtitle:@"(304) 293-3329"];
		emptyView.subtitle.numberOfLines = 2;
		emptyView.subtitle.lineBreakMode = UILineBreakModeWordWrap;
		emptyView.subtitle.font = [emptyView.subtitle.font fontWithSize:12];
		emptyView.title.font = [emptyView.title.font fontWithSize:22];
		emptyView.subtitle.clipsToBounds = NO;
		emptyView.title.clipsToBounds = NO;
		tempNewMiddleView = emptyView;
	}
	else {
		tempNewMiddleView = [[UIView alloc] initWithFrame:newRect];
		tempNewMiddleView.backgroundColor = [UIColor redColor];
	}

	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDelegate:self];
	
	//[UIView setAnimationWillStartSelector:@selector(flipMiddleViewsWithID:context:)];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:middleView cache:NO];
	
	[newMiddleView release];
	newMiddleView = tempNewMiddleView;
	[middleView addSubview:newMiddleView];
	
	
	[UIView setAnimationDuration:1];
	
	[UIView commitAnimations];
	
	
	
}


/*
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	NSString *mainText = @"";
	NSString *subText = @"";
	
	switch (indexPath.section) {
		case 0:
			mainText = @"Listen Live";
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					mainText = @"U92 Website";
					break;
				case 1:
					mainText = @"Twitter";
					subText = @"@U92WVU";
					break;
			}
			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					mainText = @"Frequency";
					subText = @"91.7 FM";
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					break;
				case 1:
					mainText = @"Call Sign";
					subText = @"WWVU-FM";
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					break;
				case 2:
					mainText = @"Power";
					subText = @"2600 W";
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					break;
				case 3:
					mainText = @"Location";
					subText = @"Mountainlair";
					break;
				case 4:
					mainText = @"Phone";
					subText = @"(304) 293-3329";
					break;
				case 5:
					mainText = @"Fax";
					subText = @"(304) 293-7363";
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					break;
				case 6:
					mainText = @"Email";
					subText = @"u92@mail.wvu.edu";
					break;
			}
			break;
	}
	
	cell.textLabel.text = mainText;
	cell.detailTextLabel.text =subText; 
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	iWVUAppDelegate *AppDelegate = [[UIApplication sharedApplication] delegate];
	
	
	
	
	if (indexPath.section == 0) {

	}
	else if(indexPath.section == 1){
		//
		
		if(indexPath.row == 0){
			OPENURL(@"http://u92.wvu.edu")
		}
		else if(indexPath.row == 1){
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			NSString *userName = [cell.detailTextLabel.text substringFromIndex:1];
			TwitterBubbleViewController *viewController = [[TwitterBubbleViewController alloc] initWithUserName:userName];
			viewController.navigationItem.title = cell.textLabel.text;
			[self.navigationController pushViewController:viewController animated:YES];
			[viewController release];
		}
	}
	else if(indexPath.section == 2){
		if(indexPath.row == 3){		
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			BuildingLocationController *theBuildingView = [[BuildingLocationController alloc] initWithNibName:@"BuildingLocation" bundle:nil];
			NSString *buildingName = @"Mountainlair";
			theBuildingView.buildingName = buildingName;
			theBuildingView.navigationItem.title = buildingName;
			[self.navigationController pushViewController:theBuildingView animated:YES];
			[theBuildingView release];
		}
		else if(indexPath.row == 4){
			NSString *phoneNum = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
			[AppDelegate callPhoneNumber:phoneNum];
		}
		else if(indexPath.row == 6){
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			[AppDelegate composeEmailTo:@"u92@mail.wvu.edu" withSubject:nil andBody:nil];
		}
	}
}




- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 0){
		return nil;
	}
	else if(section == 1){
		return @"Links";
	}
	else if(section == 2){
		return @"Information";
	}
	return nil;
}

*/


@end

