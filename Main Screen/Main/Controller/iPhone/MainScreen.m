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
#import "PRTinfo.h"
#import "U92Controller.h"
#import "BusesMain.h"
#import "EmergencyServices.h"
#import "DirectorySearch.h"
#import "DiningList.h"
#import "DAReaderViewController.h"
#import "MapFromBuildingListDriver.h"
#import "TwitterUserListViewController.h"
#import "NCAAMKalDelegate.h"
#import "KalViewController.h"


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
	tickerBar = [[[TickerBar alloc] initWithURL:rssURL andFeedName:@"WVU Today"] autorelease];
	[self.view addSubview:tickerBar];
	tickerBar.frame = CGRectMake(0, self.view.bounds.size.height-tickerBarHeight, self.view.bounds.size.width, tickerBarHeight);
	tickerBar.delegate = self;
	[tickerBar startTicker];
	

	 
	
	launcherView = [[TTLauncherView alloc] initWithFrame:launcherViewRect];
	launcherView.backgroundColor = [UIColor clearColor];
	launcherView.delegate = self;
	launcherView.columnCount = 3;
	
	//Now we need to load the user's layout preferences
  	NSArray *features = [self loadHomeScreenPosition];
	
	//We need to make sure the stored layout is from the current version
	static NSString *storedVersionKey = @"CurrentVersion";
	NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	BOOL storedFeaturesAreCurrent = [version isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:storedVersionKey]];
	
	//if it is not, delete their layout and start fresh
	if(storedFeaturesAreCurrent == NO){
		[[NSUserDefaults standardUserDefaults] setObject:version forKey:storedVersionKey];
		features == nil;
	}
	   
	
	if (features != nil) {
		launcherView.pages = features;
	}
	else {
		//the user does not have a usable stored layout
		//create the default view
		NSArray *defaultFeatures = [NSArray arrayWithObjects:
		 @"Athletics",
		 @"U92",
		 @"Directory",
		 @"Newspaper",
		 @"Twitter",
		 @"Map",
		 @"PRT",
		 @"Buses",
		 @"Libraries",
		 @"Dining",
		 @"Emergency",
		 @"WVU Mobile",
		 @"WVU Today",
		 @"WVU Alert",
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
	NSArray *multiplePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [[multiplePaths objectAtIndex:0] stringByAppendingPathComponent:@"mainScreenPages"];
	return path;
}

-(void)saveHomeScreenPosition:(NSArray *)data{
	[NSKeyedArchiver archiveRootObject:data toFile:[self filePathForHomeScreenPosition]];
}

-(NSArray *)loadHomeScreenPosition{
	return [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathForHomeScreenPosition]];
}



- (void)launcherView:(TTLauncherView*)launcher didSelectItem:(TTLauncherItem*)item{
	NSString *feature = item.title;
	
	if([@"Map" isEqualToString:feature]){
		MapFromBuildingListDriver *aDriver = [[MapFromBuildingListDriver alloc] init];
		BuildingList *theBuildingView = [[BuildingList alloc] initWithDelegate:aDriver];
		theBuildingView.navigationItem.title = @"Building Finder";
		UIBarButtonItem *backBuildingButton = [[UIBarButtonItem alloc] initWithTitle:@"Buildings" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		theBuildingView.navigationItem.backBarButtonItem = backBuildingButton;
		[backBuildingButton release];
		[self.navigationController pushViewController:theBuildingView animated:YES];
		[theBuildingView release];
	}
	else if([@"Buses" isEqualToString:feature]){
		BusesMain *theBusesView = [[BusesMain alloc] initWithStyle:UITableViewStyleGrouped];
		theBusesView.navigationItem.title = @"Mountain Line Buses";
		UIBarButtonItem *backBusesButton = [[UIBarButtonItem alloc] initWithTitle:@"Buses" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		theBusesView.navigationItem.backBarButtonItem = backBusesButton;
		[backBusesButton release];
		[self.navigationController pushViewController:theBusesView animated:YES];
		[theBusesView release];
	}
	else if([@"U92" isEqualToString:feature]){
		U92Controller *u92view = [[U92Controller alloc] initWithStyle:UITableViewStyleGrouped];
		u92view.navigationItem.title = @"U92";
		[self.navigationController pushViewController:u92view animated:YES];
		[u92view release];
	}
	else if([@"PRT" isEqualToString:feature]){
		PRTinfo *PRTview = [[PRTinfo alloc] initWithStyle:UITableViewStyleGrouped];
		PRTview.navigationItem.title = @"PRT";
		UIBarButtonItem *PRTviewButton = [[UIBarButtonItem alloc] initWithTitle:@"PRT" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		PRTview.navigationItem.backBarButtonItem = PRTviewButton;
		[PRTviewButton release];
		[self.navigationController pushViewController:PRTview animated:YES];
		[PRTview release];
	}
	else if([@"Libraries" isEqualToString:feature]){
		LibraryHours *theView = [[LibraryHours alloc] initWithStyle:UITableViewStyleGrouped];
		theView.navigationItem.title = @"WVU Libraries";
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		theView.navigationItem.backBarButtonItem = backButton;
		[backButton release];
		[self.navigationController pushViewController:theView animated:YES];
		[theView release];
	}
	else if([@"Athletics" isEqualToString:feature]){
		/*
		UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Choose a sport" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Football", @"Men's Basketball", @"Women's Basketball", @"more...", nil] autorelease];
		[actionSheet showInView:launcherView];
		 */
		
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Athletics" message:@"Choose a sport." delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"Football", @"Men's Basketball", @"Women's Basketball", @"MSNSportsNET", nil] autorelease];
		[alertView show];
		
		/*
		FootballSchedule *theSchedule = [[FootballSchedule alloc] initWithStyle:UITableViewStyleGrouped];
		theSchedule.navigationItem.title = @"WVU Football";
		UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Football" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		theSchedule.navigationItem.backBarButtonItem = abackButton;
		[abackButton release];
		[self.navigationController pushViewController:theSchedule animated:YES];
		[theSchedule release];
		 */
	}
	else if([@"Emergency" isEqualToString:feature]){
		EmergencyServices *theServView = [[EmergencyServices alloc] initWithStyle:UITableViewStyleGrouped];
		theServView.navigationItem.title = @"Emergency Services";
		UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Emergency" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		theServView.navigationItem.backBarButtonItem = abackButton;
		[abackButton release];
		[self.navigationController pushViewController:theServView animated:YES];
		[theServView release];
	}
	else if([@"Directory" isEqualToString:feature]){
		DirectorySearch *dirSer = [[DirectorySearch alloc] initWithNibName:@"DirectorySearch" bundle:nil];
		dirSer.navigationItem.title = @"Directory Search";
		UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Directory" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		dirSer.navigationItem.backBarButtonItem = abackButton;
		[abackButton release];
		[self.navigationController pushViewController:dirSer animated:YES];
		[dirSer release];
	}
	else if([@"Dining" isEqualToString:feature]){
		DiningList *dinList = [[DiningList alloc] initWithNibName:@"DiningList" bundle:nil];
		dinList.navigationItem.title = @"On-Campus Dining";
		UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Dining" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		dinList.navigationItem.backBarButtonItem = abackButton;
		[abackButton release];
		[self.navigationController pushViewController:dinList animated:YES];
		[dinList release];
	}
	else if([@"WVU Mobile" isEqualToString:feature]){
		OPENURL(@"http://m.wvu.edu")
	}
	else if([@"Newspaper" isEqualToString:feature]){
		DAReaderViewController *aDAReader = [[DAReaderViewController alloc] initWithNibName:@"DAReaderView" bundle:nil];
		aDAReader.navigationItem.title = @"The DA";
		UIBarButtonItem *aBackButton = [[UIBarButtonItem alloc] initWithTitle:@"The DA" style:UIBarButtonItemStyleBordered target:nil action:nil];
		aDAReader.navigationItem.backBarButtonItem = aBackButton;
		[aBackButton release];
		[self.navigationController pushViewController:aDAReader animated:YES];
		[aDAReader release];
	}
	else if([@"Twitter" isEqualToString:feature]){
		TwitterUserListViewController *twitterUsers = [[TwitterUserListViewController alloc] initWithStyle:UITableViewStyleGrouped];
		twitterUsers.navigationItem.title = @"WVU on Twitter";
		UIImage *flyingWVTwitter = [UIImage imageNamed:@"WVOnTwitter.png"];
		twitterUsers.navigationItem.titleView = [[[UIImageView alloc] initWithImage:flyingWVTwitter] autorelease];
		UIBarButtonItem *aBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Twitter" style:UIBarButtonItemStyleBordered target:nil action:nil];
		twitterUsers.navigationItem.backBarButtonItem = aBackButton;
		[aBackButton release];
		[self.navigationController pushViewController:twitterUsers animated:YES];
		[twitterUsers release];
	}
	else if([@"WVU.edu" isEqualToString:feature]){
		OPENURL(@"http://www.wvu.edu/?nomobi=true")
	}
	else if([@"WVU Today" isEqualToString:feature]){
		OPENURL(@"http://wvutoday.wvu.edu")
		//
	}
	else if([@"WVU Alert" isEqualToString:feature]){
		OPENURL(@"http://alert.wvu.edu")
	}
	else if([@"MIX" isEqualToString:feature]){
		OPENURL(@"http://mix.wvu.edu/")
	}
	else if([@"eCampus" isEqualToString:feature]){
		OPENURL(@"http://ecampus.wvu.edu/")
	}
	else if([@"Weather" isEqualToString:feature]){
		OPENURL(@"http://i.wund.com/cgi-bin/findweather/getForecast?brand=iphone&query=morgantown%2C+wv#conditions")
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

- (void) launcherView:(TTLauncherView  *)launcher didMoveItem:(TTLauncherItem *)item{
	[self saveHomeScreenPosition:launcherView.pages];
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
		NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
		if([title isEqualToString:@"MSNSportsNET"]){
			OPENURL(@"http://msnsportsnet.com")
		}
		else{
			NCAAMKalDelegate *driver = [[NCAAMKalDelegate alloc] init];
			KalViewController *viewController = [[KalViewController alloc] initWithDataSource:driver];
			viewController.tableViewDelegate = driver;
			driver.viewController = viewController;
			[self.navigationController pushViewController:viewController animated:YES];
			[viewController release];
		}
	}
}


-(void)tickerBar:(TickerBar *)ticker itemSelected:(NSString *)aURL{
	OPENURL(aURL);
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
