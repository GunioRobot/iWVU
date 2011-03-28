//
//  TwitterUserListViewController.m
//  iWVU
//
//  Created by Jared Crawford on 10/5/09.
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

#import "TwitterUserListViewController.h"
#import "TwitterBubbleViewController.h"
#import "MGSplitViewController.h"

#define PARENT_TWITTER_ACCOUNT @"WestVirginiaU"
#define PARENTS_LIST_TO_DISPLAY @"all"
#define DETAIL_PREFIX @"    @"

@interface TwitterUserListViewController (Private)
-(void)loadLocallyStoredUserList;
@end

@implementation TwitterUserListViewController

@synthesize userData;
@synthesize userNames;





- (void)viewDidLoad {
    [super viewDidLoad];

	
	//first we'll store what we have in cache
	[self loadLocallyStoredUserList];
	
	//Then we'll download the most recent data from the list
	
	
	twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
	
	[twitterEngine getMembersFromList:PARENTS_LIST_TO_DISPLAY onAccount:PARENT_TWITTER_ACCOUNT];
	
	//lagacy code used to download a plist file with twitter names in it
	//pre Twitter-lists
	/*
	 NSThread *listDownloadThread = [[NSThread alloc] initWithTarget:self selector:@selector(getMostRecentUserList) object:nil];
	 [listDownloadThread start];
	 [listDownloadThread release];
	 */
	
	
	
	
	
}



-(NSString *)filePathForLocallyStoredUserList{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	return [path stringByAppendingPathComponent:@"twitter.plist"];
}

-(void)loadLocallyStoredUserList{

	NSString *filePath = [self filePathForLocallyStoredUserList];
	
	//if there isn't a cached local copy of the internet version, move the bundle resource there.
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO) {
		NSError *anError;
		NSString *fromPath = [[NSBundle mainBundle] pathForResource:@"twitter" ofType:@"plist"];
		[[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:filePath error:&anError];
	}
	
	self.userData = [NSDictionary dictionaryWithContentsOfFile:filePath];
	
	//create an alphabetical list of the user names
	NSMutableArray *tempUserNames = [NSMutableArray array];
	for (NSString *name in userData) {
		[tempUserNames addObject:name];
	}
	[tempUserNames sortUsingSelector:@selector(compare:)];
	self.userNames =  [NSArray arrayWithArray:tempUserNames];
	
}


-(void)getMostRecentUserList{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSURL *url = [NSURL URLWithString:@"http://iwvu.sitespace.wvu.edu/twitter.plist"];
	NSData *data = [NSData dataWithContentsOfURL:url];
	
	if (data) {
		[data writeToFile:[self filePathForLocallyStoredUserList] atomically:YES];
	}
	
	[pool release];
}



#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	//these are the default's, but I'm going to explicitly define them, just to be safe
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		return (UIInterfaceOrientationPortrait == interfaceOrientation);
	}
	return YES;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;
	}
	else if (userData) {
		//section 1
		return [userData count];
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	
	
	if (indexPath.section == 0) {
		cell.textLabel.text = @"All Twitter Accounts";
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@/%@",DETAIL_PREFIX, PARENT_TWITTER_ACCOUNT, PARENTS_LIST_TO_DISPLAY];
		cell.detailTextLabel.textColor = [UIColor whiteColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	if (indexPath.section == 1) {
		cell.textLabel.text = [userNames objectAtIndex:indexPath.row];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@",DETAIL_PREFIX, [userData objectForKey:cell.textLabel.text]];
		cell.detailTextLabel.textColor = [UIColor blackColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	
	
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	[AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		TwitterBubbleViewController *viewController;
		if (indexPath.section == 0) {
			viewController = [[TwitterBubbleViewController alloc] initWithList:PARENTS_LIST_TO_DISPLAY onUserName:PARENT_TWITTER_ACCOUNT];
		}
		else {
			NSString *userName = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:DETAIL_PREFIX withString:@""];
			viewController = [[TwitterBubbleViewController alloc] initWithUserName:userName];
		}
		
		viewController.navigationItem.title = cell.textLabel.text;
		[self.navigationController pushViewController:viewController animated:YES];
		[viewController release];
	}
	else {
		iWVUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
		MGSplitViewController *splitViewController= appDelegate.navigationController.visibleViewController;
		TwitterBubbleViewController *bubbleView = [[splitViewController viewControllers] objectAtIndex:1];
		if (indexPath.section == 0) {
			[bubbleView updateList:PARENTS_LIST_TO_DISPLAY onUserName:PARENT_TWITTER_ACCOUNT];
		}
		else {
			NSString *userName = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:DETAIL_PREFIX withString:@""];
			[bubbleView updateUserName:userName];
		}
		
		
	}
}


- (void)userListsReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier{
	//implement storage code here
	
	
	//userList = [userInfo sorted];
	//userData = dictionary;
	
    NSLog(@"For some reason, this code isn't being called. The function below says it was a success though. Need to investigate");
    
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}



- (void)requestSucceeded:(NSString *)connectionIdentifier{
	NSLog(@"User list request SUCCESS!!!! Now write some code to store this data.");
}
- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error{
	//silently fail, fallback to the stored list
	//NSLog(@"Downloading of user list failed. This call will always fail until Twitter resolves API issue 1297.");
}




#pragma mark Memory

- (void)dealloc {
	[twitterEngine closeAllConnections];
	[twitterEngine release];
    self.userData = nil;
	self.userNames = nil;
	[super dealloc];
}


@end

