//
//  TwitterBubbleViewController.m
//  iWVU
//
//  Created by Jared Crawford on 10/4/09.
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

#import "TwitterBubbleViewController.h"
#import "TwitterUserListViewController.h"

@implementation TwitterBubbleViewController



-(id)initWithUserName:(NSString *)aUserName{
	if (self = [self init]) {
		[twitterView setTwitterUserName:aUserName];
	}
	return self;
}


-(id)initWithList:(NSString *)listName onUserName:(NSString *)aUserName{
	if (self = [self init]) {
		[twitterView setTwitterList:listName onAccount:aUserName];
	}
	return self;
}


-(id)init{
	if (self = [super init]) {
		twitterView = [[TwitterTableView alloc] initWithFrame:self.view.bounds];
		[self.view addSubview:twitterView];
	}
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(displayUserList)];
		self.navigationItem.rightBarButtonItem = barButton;
		[barButton release];
	}
	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}



-(void)viewDidDisappear:(BOOL)animated{

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}





- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}



- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)dealloc {
    [super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	//these are the default's, but I'm going to explicitly define them, just to be safe
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		return NO;
	}
	return YES;
}



-(void)replyToUser{
	NSString *aTitle = [NSString stringWithFormat:@"Reply to @%@", [twitterView getUserName]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:aTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Twitter", @"Twitter.com", nil];
	[actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	NSString *chosenTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	if (buttonIndex != actionSheet.cancelButtonIndex) {
		NSString *atUsername = [NSString stringWithFormat:@"%@%@",@"@",[twitterView getUserName]];
		if([chosenTitle isEqualToString:@"Twitter"]){
			NSString *url = [NSString stringWithFormat:@"tweetie:///post?message=%@", atUsername];
            [AppDelegate callExternalApplication:chosenTitle withURL:url];
		}
		else if([chosenTitle isEqualToString:@"Twitter.com"]){
			NSString *url = [NSString stringWithFormat:@"http://twitter.com/%@",[twitterView getUserName]];
            OPENURL(url);
		}
		
	}
}



-(void)displayUserList{
	//this method is not called on iPad
	//the split view controller manages the views for that
	TwitterUserListViewController *twitterUsers = [[TwitterUserListViewController alloc] initWithStyle:UITableViewStyleGrouped];
	twitterUsers.navigationItem.title = @"WVU Twitter Accounts";
	[self.navigationController pushViewController:twitterUsers animated:YES];
}

-(void)updateUserName:(NSString *)userName{
	[twitterView setTwitterUserName:userName];
	self.navigationItem.title = [NSString stringWithFormat:@"@%@", userName];
}


-(void)updateList:(NSString *)listName onUserName:(NSString *)aUserName{
	[twitterView setTwitterList:listName onAccount:aUserName];
	self.navigationItem.title = [NSString stringWithFormat:@"@%@/%@", aUserName, listName];
}


#pragma mark UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc{
	barButtonItem.title = @"WVU Twitter Accounts";
	self.navigationItem.rightBarButtonItem = barButtonItem;
}


- (void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button{
	if ((self.navigationItem.rightBarButtonItem = button)) {
		self.navigationItem.rightBarButtonItem = nil;
	}
}


@end
