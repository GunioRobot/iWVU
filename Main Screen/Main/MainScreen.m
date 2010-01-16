//
//  MainScreen.m
//  iWVU
//
//  Created by Jared Crawford on 1/2/10.
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

#import "MainScreen.h"


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


#define BAR_SLIDE_INOUT_DURATION .5

@implementation MainScreen



- (void)loadView {
	[super loadView];
	
	self.navigationBarTintColor = [UIColor WVUBlueColor];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings.png"] style:UIBarButtonItemStyleBordered target:self action:nil] autorelease];
	self.view.backgroundColor = [UIColor viewBackgroundColor];
	
	
	float tickerBarHeight = 35;
	CGRect launcherViewRect = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-tickerBarHeight);
	
	NSURL *rssURL = [NSURL URLWithString:@"http://wvutoday.wvu.edu/n/rss/"];
	tickerBar = [[[TickerBar alloc] initWithURL:rssURL] autorelease];
	[self.view addSubview:tickerBar];
	tickerBar.frame = CGRectMake(0, self.view.bounds.size.height-tickerBarHeight, self.view.bounds.size.width, tickerBarHeight);
	tickerBar.text = @"Loading WVU Today...";
	tickerBar.delegate = self;
	[tickerBar startTicker];
	

	 
	
	launcherView = [[TTLauncherView alloc] initWithFrame:launcherViewRect];
	launcherView.backgroundColor = [UIColor clearColor];
	launcherView.delegate = self;
	launcherView.columnCount = 3;
	
	TTNavigator* navigator = [TTNavigator navigator];
	navigator.window = [UIApplication sharedApplication].keyWindow;
	TTURLMap* map = navigator.URLMap;
	[map from:@"bundle://mainScreen/(featureSelectedNamed:)" toViewController:[MainScreen class]];
	
	
  	NSArray *features = [self loadHomeScreenPosition];
	
	if (features != nil) {
		launcherView.pages = features;
	}
	else {
		//create the default view
		NSArray *defaultFeatures = [NSArray arrayWithObjects:
		 @"athletics",
		 @"U92",
		 @"directory",
		 @"newspaper",
		 @"twitter",
		 @"map",
		 @"PRT",
		 @"buses",
		 @"libraries",
		 @"dining",
		 @"emergency",
		 @"WVU mobile",
		 @"WVU today",
		 @"WVU alert",
		 @"eCampus",
		 @"MIX",
		 @"WVU.edu",
		 nil];
		
		NSMutableArray *pageItems = [NSMutableArray array];
		NSMutableArray *pageList = [NSMutableArray array];
		int itemsInPage = 9;
		int i = 0;

		
		for (NSString *feature in defaultFeatures) {
			if ((i%itemsInPage == 0)&&(i!=0)) {
				[pageList addObject:[NSArray arrayWithArray:pageItems]];
				pageItems = [NSMutableArray array];
			}
			
			NSString *escapedString = [feature stringByReplacingOccurrencesOfString:@" " withString:@"_"];
			escapedString = [escapedString stringByReplacingOccurrencesOfString:@"." withString:@"_"];
			
			NSString *imageURL = [NSString stringWithFormat:@"bundle://Main_%@.png",escapedString];
			
			NSString *selectorURL = [NSString stringWithFormat:@"bundle://mainScreen/%@", feature];
			
			TTLauncherItem *item = [[[TTLauncherItem alloc] initWithTitle:feature
																	image:imageURL
																	  URL:selectorURL canDelete:NO] autorelease];
			
			item.style = @"mainScreenLauncherButton:";
			[pageItems addObject:item];
			i++;
			
		}
		[pageList addObject:[NSArray arrayWithArray:pageItems]];
		launcherView.pages = [NSArray arrayWithArray:pageList];					 
	}
	[self saveHomeScreenPosition:launcherView.pages];
	[self.view addSubview:launcherView];
	[self.view sendSubviewToBack:launcherView];
}



-(NSString *)filePathForHomeScreenPosition{	
	NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"mainScreenPages"];
	//path = [path stringByAppendingPathComponent:@"scoreData"];
	NSLog(@"%@", path);
	return path;
}

-(void)saveHomeScreenPosition:(NSArray *)data{
	
	BOOL success = [NSKeyedArchiver archiveRootObject:data toFile:[self filePathForHomeScreenPosition]];
	//NSCoder *code = [[NSCoder alloc] init]
	
	if (success == NO) {
		NSLog(@"Writing to file failed.");
	}
}

-(NSArray *)loadHomeScreenPosition{
	return [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathForHomeScreenPosition]];
}



- (void)launcherView:(TTLauncherView*)launcher didSelectItem:(TTLauncherItem*)item{
	NSString *feature = item.title;
	
	iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	
	if([@"map" isEqualToString:feature]){
		MapFromBuildingListDriver *aDriver = [[MapFromBuildingListDriver alloc] init];
		BuildingList *theBuildingView = [[BuildingList alloc] initWithDelegate:aDriver];
		theBuildingView.navigationItem.title = @"Building Finder";
		UIBarButtonItem *backBuildingButton = [[UIBarButtonItem alloc] initWithTitle:@"Buildings" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		theBuildingView.navigationItem.backBarButtonItem = backBuildingButton;
		[backBuildingButton release];
		[AppDelegate.navigationController pushViewController:theBuildingView animated:YES];
		[theBuildingView release];
	}
	else if([@"buses" isEqualToString:feature]){
		BusesMain *theBusesView = [[BusesMain alloc] initWithStyle:UITableViewStyleGrouped];
		theBusesView.navigationItem.title = @"Mountain Line Buses";
		UIBarButtonItem *backBusesButton = [[UIBarButtonItem alloc] initWithTitle:@"Buses" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		theBusesView.navigationItem.backBarButtonItem = backBusesButton;
		[backBusesButton release];
		[AppDelegate.navigationController pushViewController:theBusesView animated:YES];
		[theBusesView release];
	}
	else if([@"U92" isEqualToString:feature]){
		U92Controller *u92view = [[U92Controller alloc] initWithStyle:UITableViewStyleGrouped];
		u92view.navigationItem.title = @"U92";
		[AppDelegate.navigationController pushViewController:u92view animated:YES];
		[u92view release];
	}
	else if([@"PRT" isEqualToString:feature]){
		PRTinfo *PRTview = [[PRTinfo alloc] initWithStyle:UITableViewStyleGrouped];
		PRTview.navigationItem.title = @"PRT";
		UIBarButtonItem *PRTviewButton = [[UIBarButtonItem alloc] initWithTitle:@"PRT" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		PRTview.navigationItem.backBarButtonItem = PRTviewButton;
		[PRTviewButton release];
		[AppDelegate.navigationController pushViewController:PRTview animated:YES];
		[PRTview release];
	}
	else if([@"libraries" isEqualToString:feature]){
		LibraryHours *theView = [[LibraryHours alloc] initWithStyle:UITableViewStyleGrouped];
		theView.navigationItem.title = @"WVU Libraries";
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		theView.navigationItem.backBarButtonItem = backButton;
		[backButton release];
		[AppDelegate.navigationController pushViewController:theView animated:YES];
		[theView release];
	}
	else if([@"athletics" isEqualToString:feature]){
		/*
		UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Choose a sport" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Football", @"Men's Basketball", @"Women's Basketball", @"more...", nil] autorelease];
		[actionSheet showInView:launcherView];
		 */
		
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Athletics" message:@"Choose a sport." delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"Football", @"Men's Basketball", @"Women's Basketball", @"more...", nil] autorelease];
		[alertView show];
		
		/*
		FootballSchedule *theSchedule = [[FootballSchedule alloc] initWithStyle:UITableViewStyleGrouped];
		theSchedule.navigationItem.title = @"WVU Football";
		UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Football" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		theSchedule.navigationItem.backBarButtonItem = abackButton;
		[abackButton release];
		[AppDelegate.navigationController pushViewController:theSchedule animated:YES];
		[theSchedule release];
		 */
	}
	else if([@"emergency" isEqualToString:feature]){
		EmergencyServices *theServView = [[EmergencyServices alloc] initWithStyle:UITableViewStyleGrouped];
		theServView.navigationItem.title = @"Emergency Services";
		UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Emergency" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		theServView.navigationItem.backBarButtonItem = abackButton;
		[abackButton release];
		[AppDelegate.navigationController pushViewController:theServView animated:YES];
		[theServView release];
	}
	else if([@"directory" isEqualToString:feature]){
		DirectorySearch *dirSer = [[DirectorySearch alloc] initWithNibName:@"DirectorySearch" bundle:nil];
		dirSer.navigationItem.title = @"Directory Search";
		UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Directory" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		dirSer.navigationItem.backBarButtonItem = abackButton;
		[abackButton release];
		[AppDelegate.navigationController pushViewController:dirSer animated:YES];
		[dirSer release];
	}
	else if([@"dining" isEqualToString:feature]){
		DiningList *dinList = [[DiningList alloc] initWithNibName:@"DiningList" bundle:nil];
		dinList.navigationItem.title = @"On-Campus Dining";
		UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Dining" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		dinList.navigationItem.backBarButtonItem = abackButton;
		[abackButton release];
		[AppDelegate.navigationController pushViewController:dinList animated:YES];
		[dinList release];
	}
	else if([@"WVU mobile" isEqualToString:feature]){
		[AppDelegate loadWebViewWithURL:@"http://m.wvu.edu" andTitle:@"WVU mobile"];
	}
	else if([@"newspaper" isEqualToString:feature]){
		DAReaderViewController *aDAReader = [[DAReaderViewController alloc] initWithNibName:@"DAReaderView" bundle:nil];
		aDAReader.navigationItem.title = @"The DA";
		UIBarButtonItem *aBackButton = [[UIBarButtonItem alloc] initWithTitle:@"The DA" style:UIBarButtonItemStyleBordered target:nil action:nil];
		aDAReader.navigationItem.backBarButtonItem = aBackButton;
		[aBackButton release];
		[AppDelegate.navigationController pushViewController:aDAReader animated:YES];
		[aDAReader release];
	}
	else if([@"twitter" isEqualToString:feature]){
		TwitterUserListViewController *twitterUsers = [[TwitterUserListViewController alloc] initWithStyle:UITableViewStyleGrouped];
		twitterUsers.navigationItem.title = @"WVU on Twitter";
		UIImage *flyingWVTwitter = [UIImage imageNamed:@"WVOnTwitter.png"];
		twitterUsers.navigationItem.titleView = [[[UIImageView alloc] initWithImage:flyingWVTwitter] autorelease];
		UIBarButtonItem *aBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Twitter" style:UIBarButtonItemStyleBordered target:nil action:nil];
		twitterUsers.navigationItem.backBarButtonItem = aBackButton;
		[aBackButton release];
		[AppDelegate.navigationController pushViewController:twitterUsers animated:YES];
		[twitterUsers release];
	}
	else if([@"WVU.edu" isEqualToString:feature]){
		[AppDelegate loadWebViewWithURL:@"http://www.wvu.edu/?nomobi=true" andTitle:feature];
	}
	else if([@"WVU today" isEqualToString:feature]){
		[AppDelegate loadWebViewWithURL:@"http://wvutoday.wvu.edu" andTitle:feature];
		//
	}
	else if([@"WVU alert" isEqualToString:feature]){
		[AppDelegate loadWebViewWithURL:@"http://alert.wvu.edu" andTitle:feature];
	}
	else if([@"MIX" isEqualToString:feature]){
		[AppDelegate loadWebViewWithURL:@"http://mix.wvu.edu/" andTitle:feature];
	}
	else if([@"eCampus" isEqualToString:feature]){
		[AppDelegate loadWebViewWithURL:@"http://ecampus.wvu.edu/" andTitle:feature];
	}
	else if([@"weather" isEqualToString:feature]){
		[AppDelegate loadWebViewWithURL:@"http://i.wund.com/cgi-bin/findweather/getForecast?brand=iphone&query=morgantown%2C+wv#conditions" andTitle:feature];
	}


	
}

- (void)launcherViewDidBeginEditing:(TTLauncherView*)launcher {
	doneEditingBar = [[DoneEditingBar createBar] retain];
	doneEditingBar.delegate = self;
	[self.view addSubview:doneEditingBar];
	doneEditingBar.frame = tickerBar.frame;
	doneEditingBar.hidden = YES;
	
	[tickerBar slideOutTo:kFTAnimationBottom duration:BAR_SLIDE_INOUT_DURATION delegate:self startSelector:nil stopSelector:@selector(displayDoneEditingBar)];
	
	
	
}

- (void)launcherViewDidEndEditing:(TTLauncherView*)launcher {
	[self saveHomeScreenPosition:launcherView.pages];
}

-(void)displayDoneEditingBar{
	doneEditingBar.hidden = NO;
	[doneEditingBar slideInFrom:kFTAnimationBottom duration:BAR_SLIDE_INOUT_DURATION delegate:nil];
}

-(void)doneEditingBarHasFinished:(DoneEditingBar *)bar{
	[launcherView endEditing];
	[doneEditingBar slideOutTo:kFTAnimationBottom duration:BAR_SLIDE_INOUT_DURATION delegate:self startSelector:nil stopSelector:@selector(displayTickerBar)];
}

-(void)displayTickerBar{
	[tickerBar slideInFrom:kFTAnimationBottom duration:BAR_SLIDE_INOUT_DURATION delegate:nil];
	[doneEditingBar release];
	doneEditingBar = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex != alertView.cancelButtonIndex) {
		iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
		FootballSchedule *theSchedule = [[FootballSchedule alloc] initWithStyle:UITableViewStyleGrouped];
		theSchedule.navigationItem.title = @"WVU Football";
		UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Football" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		theSchedule.navigationItem.backBarButtonItem = abackButton;
		[abackButton release];
		[AppDelegate.navigationController pushViewController:theSchedule animated:YES];
		[theSchedule release];
	}
}


-(void)tickerBar:(TickerBar *)ticker itemSelected:(NSString *)labelText{
	for (FPItem *newsItem in newsFeed.items) {
		if ([newsItem.title isEqualToString:labelText]) {
			iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
			[AppDelegate loadWebViewWithURL:newsItem.link.href andTitle:newsItem.title];
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


- (void)dealloc {
    [super dealloc];
}


@end
