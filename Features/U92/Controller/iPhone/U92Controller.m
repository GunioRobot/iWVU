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
	
	showLabel.text = @"Loading...";
	showLabel.font = [UIFont systemFontOfSize:25];
	showLabel.textAlignment = UITextAlignmentLeft;
	showLabel.contentMode = UIViewContentModeCenter;
	showLabel.backgroundColor = [UIColor clearColor];
	showLabel.textColor = [UIColor grayColor];
	showLabel.spotlightColor = [UIColor whiteColor];

	
	
	if ([[UIApplication sharedApplication] isStreamingRadio]) {
		[playPauseButton setImage:[UIImage imageNamed:@"PauseButton.png"] forState:UIControlStateNormal];
	}
	else {
		[playPauseButton setImage:[UIImage imageNamed:@"PlayButton.png"] forState:UIControlStateNormal];;
	}
	
    detailsEngine = [[RadioDetails alloc] init];
	[detailsEngine addObserver:self forKeyPath:@"currentShow" options:NSKeyValueObservingOptionNew context:nil];
}


-(void)viewWillAppear:(BOOL)animated{
	[self layoutButtons];
	float middleWidth = self.view.frame.size.width;
	float middleY = streamerBackground.frame.origin.y + streamerBackground.frame.size.height;
	float middleHeight = toolbar.frame.origin.y - middleY;
	
	middleView.frame = CGRectMake(0, middleY, middleWidth, middleHeight);
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	//these are the default's, but I'm going to explicitly define them, just to be safe
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		return NO;
	}
	return YES;
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
		[playPauseButton setImage:[UIImage imageNamed:@"PlayButton.png"] forState:UIControlStateNormal];
	}
	else {
		[playPauseButton setImage:[UIImage imageNamed:@"PauseButton.png"] forState:UIControlStateNormal];;
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
		TKEmptyView *emptyView = [[TKEmptyView alloc] initWithFrame:newRect mask:[UIImage imageNamed:@"RadioEmptyView.png"] title:@"Email U92" subtitle:@""];
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
		TKEmptyView *emptyView = [[TKEmptyView alloc] initWithFrame:newRect mask:[UIImage imageNamed:@"RadioEmptyView.png"] title:@"Call U92" subtitle:@"(304) 293-3329"];
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
	
	[newMiddleView removeFromSuperview];
	[newMiddleView release];
	newMiddleView = tempNewMiddleView;
	[middleView addSubview:newMiddleView];
	
	
	[UIView setAnimationDuration:1];
	
	[UIView commitAnimations];
	
	
	
}



@end

