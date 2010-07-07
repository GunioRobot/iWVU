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


#define DETAIL_PREFIX @"    @"

@implementation TwitterUserListViewController

@synthesize userData;
@synthesize userNames;


- (void)viewDidLoad {
    [super viewDidLoad];

	NSThread *listDownloadThread = [[NSThread alloc] initWithTarget:self selector:@selector(getMostRecentUserList) object:nil];
	[listDownloadThread start];
	[listDownloadThread release];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	NSString *filePath = [path stringByAppendingPathComponent:@"twitter.plist"];
	
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
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	NSString *filePath = [path stringByAppendingPathComponent:@"twitter.plist"];
	
	if (data) {
		[data writeToFile:filePath atomically:YES];
	}
	
	[pool release];
}



#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	//these are the default's, but I'm going to explicitly define them, just to be safe
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		return NO;
	}
	return YES;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (userData) {
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
		cell.textLabel.text = [userNames objectAtIndex:indexPath.row];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@",DETAIL_PREFIX, [userData objectForKey:cell.textLabel.text]];
		cell.detailTextLabel.textColor = [UIColor whiteColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	
	
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 0) {

		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		NSString *userName = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:DETAIL_PREFIX withString:@""];
		TwitterBubbleViewController *viewController = [[TwitterBubbleViewController alloc] initWithUserName:userName];
		viewController.navigationItem.title = cell.textLabel.text;
		[self.navigationController pushViewController:viewController animated:YES];
		[viewController release];
		
	}
}

#pragma mark Memory

- (void)dealloc {
    self.userData = nil;
	self.userNames = nil;
	[super dealloc];
}


@end

