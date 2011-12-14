//
//  MainScreen.m
//  iWVU
//
//  Created by Jared Crawford on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainScreen.h"

@implementation MainScreen
@synthesize tableView;


#import "BuildingList.h"
#import "LibraryHours.h"
#import "PRTinfo.h"
#import "RadioViewController.h"
#import "BusesMain.h"
#import "EmergencyServices.h"
#import "DirectorySearch.h"
#import "DiningList.h"
#import "MapFromBuildingListDriver.h"
//#import "TwitterUserListViewController.h"
#import "CalendarSourcesViewController.h"
#import "SportsListViewController.h"
#import "SettingsViewController.h"
//#import "TwitterBubbleViewController.h"
#import "BuildingSplitViewController.h"
#import "BuildingLocationController.h"
#import "NewspaperSelectionViewController.h"


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:tableView];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return YES;
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 21;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        return;
    }
    NSString *feature = cell.textLabel.text;
	
	UIViewController *viewController = nil;
	BOOL iPadCompatible = NO;
	
	if([@"Map" isEqualToString:feature]){
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
			viewController = [[BuildingSplitViewController alloc] init];
			iPadCompatible = YES;
		}
		else {
			MapFromBuildingListDriver *aDriver = [[MapFromBuildingListDriver alloc] init];
			BuildingList *theBuildingView = [[BuildingList alloc] initWithDelegate:aDriver];
			theBuildingView.navigationItem.title = @"Building Finder";
			UIBarButtonItem *backBuildingButton = [[UIBarButtonItem alloc] initWithTitle:@"Buildings" style:UIBarButtonItemStyleBordered	target:nil action:nil];
			theBuildingView.navigationItem.backBarButtonItem = backBuildingButton;
			viewController = theBuildingView;
		}		
	}
	else if([@"Buses" isEqualToString:feature]){
		BusesMain *theBusesView = [[BusesMain alloc] initWithStyle:UITableViewStyleGrouped];
		theBusesView.navigationItem.title = @"Mountain Line Buses";
		UIBarButtonItem *backBusesButton = [[UIBarButtonItem alloc] initWithTitle:@"Buses" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		theBusesView.navigationItem.backBarButtonItem = backBusesButton;
		viewController = theBusesView;
	}
	else if([@"Radio" isEqualToString:feature]){
        RadioViewController *u92view = [[RadioViewController alloc] initWithNibName:@"RadioViewController" bundle:nil];
		u92view.navigationItem.title = @"U92";
		viewController = u92view;
	}
	else if([@"PRT" isEqualToString:feature]){
		PRTinfo *PRTview = [[PRTinfo alloc] initWithStyle:UITableViewStyleGrouped];
		PRTview.navigationItem.title = @"PRT";
		UIBarButtonItem *PRTviewButton = [[UIBarButtonItem alloc] initWithTitle:@"PRT" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		PRTview.navigationItem.backBarButtonItem = PRTviewButton;
		viewController = PRTview;
	}
	else if([@"Libraries" isEqualToString:feature]){
		LibraryHours *theView = [[LibraryHours alloc] initWithStyle:UITableViewStyleGrouped];
		theView.navigationItem.title = @"WVU Libraries";
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		theView.navigationItem.backBarButtonItem = backButton;
		viewController = theView;
	}
	else if([@"Athletics" isEqualToString:feature]){
		SportsListViewController *sportsList = [[SportsListViewController alloc] initWithStyle:UITableViewStyleGrouped];
		sportsList.navigationItem.title = @"WVU Athletics";
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Athletics" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		sportsList.navigationItem.backBarButtonItem = backButton;
		viewController = sportsList;
	}
	else if([@"Emergency" isEqualToString:feature]){
		EmergencyServices *theServView = [[EmergencyServices alloc] initWithStyle:UITableViewStyleGrouped];
		theServView.navigationItem.title = @"Emergency Services";
		UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Emergency" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		theServView.navigationItem.backBarButtonItem = abackButton;
		viewController = theServView;
	}
	else if([@"Directory" isEqualToString:feature]){
		DirectorySearch *dirSer = [[DirectorySearch alloc] initWithNibName:@"DirectorySearch" bundle:nil];
		dirSer.navigationItem.title = @"Directory Search";
		UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Directory" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		dirSer.navigationItem.backBarButtonItem = abackButton;
		viewController = dirSer;
	}
	else if([@"Dining" isEqualToString:feature]){
		DiningList *dinList = [[DiningList alloc] initWithNibName:@"DiningList" bundle:nil];
		dinList.navigationItem.title = @"On-Campus Dining";
		UIBarButtonItem *abackButton = [[UIBarButtonItem alloc] initWithTitle:@"Dining" style:UIBarButtonItemStyleBordered	target:nil action:nil];
		dinList.navigationItem.backBarButtonItem = abackButton;
		viewController = dinList;
	}
	else if([@"WVU Mobile" isEqualToString:feature]){
		OPENURL(@"http://m.wvu.edu")
	}
	else if([@"Newspaper" isEqualToString:feature]){
		
		viewController = [[NewspaperSelectionViewController alloc] init];
		//iPadCompatible = YES;
		
	}
	else if([@"Settings" isEqualToString:feature]){
		SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
		settingsViewController.title = @"Settings";
		viewController = settingsViewController;
	}
	else if([@"Twitter" isEqualToString:feature]){
		/*
		TwitterBubbleViewController *bubbleViewController = [[TwitterBubbleViewController alloc] initWithList:@"wvu" onUserName:@"iWVU"];
		
		
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
			TwitterUserListViewController *twitterUsers = [[TwitterUserListViewController alloc] initWithStyle:UITableViewStyleGrouped];
			twitterUsers.navigationItem.title = @"WVU Twitter Accounts";
			NSArray *viewControllers = [NSArray arrayWithObjects:twitterUsers, bubbleViewController, nil];
			MGSplitViewController *splitViewController = [[MGSplitViewController alloc] init];
			splitViewController.delegate = bubbleViewController;
			splitViewController.viewControllers = viewControllers;
			viewController = splitViewController;
			[bubbleViewController release];
			[twitterUsers release];
			iPadCompatible = YES;
		}
		else {
			viewController = bubbleViewController;
		}
		viewController.navigationItem.title = @"All WVU";
		UIImage *flyingWVTwitter = [UIImage imageNamed:@"WVOnTwitter.png"];
		viewController.navigationItem.titleView = [[[UIImageView alloc] initWithImage:flyingWVTwitter] autorelease];
		
		*/
	}
	else if([@"Calendar" isEqualToString:feature]){
		CalendarSourcesViewController *calendarViewController = [[CalendarSourcesViewController alloc] initWithStyle:UITableViewStyleGrouped];
		calendarViewController.navigationItem.title = @"Calendar Sources";
		UIBarButtonItem *aBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Sources" style:UIBarButtonItemStyleBordered target:nil action:nil];
		calendarViewController.navigationItem.backBarButtonItem = aBackButton;
		viewController = calendarViewController;
	}
	else if([@"WVU.edu" isEqualToString:feature]){
		OPENURL(@"http://www.wvu.edu/?nomobi=true")
	}
	else if([@"WVU Today" isEqualToString:feature]){
		OPENURL(@"http://wvutoday.wvu.edu")
	}
	else if([@"WVU Alert" isEqualToString:feature]){
		OPENURL(@"http://alert.wvu.edu")
	}
	else if([@"MIX" isEqualToString:feature]){
		OPENURL(@"http://mixinfo.wvu.edu/directions_for_iphones/#content")
	}
	else if([@"eCampus" isEqualToString:feature]){
		OPENURL(@"http://ecampus.wvu.edu/")
	}
	else if([@"Weather" isEqualToString:feature]){
		OPENURL(@"http://i.wund.com/cgi-bin/findweather/getForecast?brand=iphone&query=morgantown%2C+wv#conditions")
	}
	
	
	
	
	if (viewController) {
		if (([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)||(iPadCompatible)) {
			[self.navigationController pushViewController:viewController animated:YES];
		}
		else {
			UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissForm)];
			viewController.navigationItem.leftBarButtonItem = closeButton;
			UINavigationController *modalNavCont = [[UINavigationController alloc] initWithRootViewController:viewController];
			modalNavCont.navigationBar.tintColor = [UIColor applicationPrimaryColor];
			modalNavCont.modalPresentationStyle = UIModalPresentationFormSheet;
			modalNavCont.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
			[self presentModalViewController:modalNavCont animated:YES];
		}
	}	
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";	
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	cell.detailTextLabel.textColor = [UIColor applicationPrimaryColor];
	
	NSString *mainText = @"";
	NSString *subText = @"";
	
    switch (indexPath.row) {
        case 0:
            mainText = @"Buses";
            break;
        case 1:
            mainText = @"Map";
            break;
        case 2:
            mainText = @"Radio";
            break;
        case 3:
            mainText = @"PRT";
            break; 
        case 4:
            mainText = @"Libraries";
            break;
        case 5:
            mainText = @"Athletics";
            break;
        case 6:
            mainText = @"Emergency";
            break;
        case 7:
            mainText = @"Directory";
            break;
        case 8:
            mainText = @"Dining";
            break;
        case 9:
            mainText = @"WVU Mobile";
            break;
        case 10:
            mainText = @"Newspaper";
            break;
        case 11:
            mainText = @"Settings";
            break;
        case 12:
            mainText = @"Twitter";
            break;
        case 13:
            mainText = @"Calendar";
            break;
        case 14:
            mainText = @"WVU.edu";
            break;
        case 15:
            mainText = @"WVU Today";
            break;
        case 16:
            mainText = @"WVU Alert";
            break;
        case 17:
            mainText = @"Mix";
            break;
        case 18:
            mainText = @"eCampus";
            break;
        case 19:
            mainText = @"Weather";
            break;
            
	}
    cell.textLabel.text = mainText;
    cell.detailTextLabel.text = subText;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)dismissForm{
	if (self.modalViewController) {
		[self dismissModalViewControllerAnimated:YES];
	}
}

@end
