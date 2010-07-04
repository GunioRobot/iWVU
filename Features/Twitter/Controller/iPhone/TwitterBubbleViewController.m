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


@implementation TwitterBubbleViewController



-(id)initWithUserName:(NSString *)aUserName{
	if (self = [super init]) {
		twitterView = [[TwitterTableView alloc] initWithFrame:self.view.bounds];
		[self.view addSubview:twitterView];
		twitterView.twitterUserName = aUserName;
	}
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(replyToUser)];
	self.navigationItem.rightBarButtonItem = barButton;
	[barButton release];
	
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




-(void)replyToUser{
	NSString *aTitle = [NSString stringWithFormat:@"Reply to @%@", twitterView.twitterUserName];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:aTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Echofon", @"Tweetie", @"Twittelator Pro", @"Twitterriffic", @"Web", nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	NSString *chosenTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	if (buttonIndex != actionSheet.cancelButtonIndex) {
		NSString *atUsername = [NSString stringWithFormat:@"%@%@",@"@",twitterView.twitterUserName];
		NSString *url = @"";
		if([chosenTitle isEqualToString:@"Echofon"]){
			url = [NSString stringWithFormat:@"twitterfon:///post?%@",atUsername];
		}
		else if([chosenTitle isEqualToString:@"Tweetie"]){
			url = [NSString stringWithFormat:@"tweetie:///post?message=%@", atUsername];
		}
		else if([chosenTitle isEqualToString:@"Web"]){
			url = [NSString stringWithFormat:@"http://twitter.com/%@",twitterView.twitterUserName];
		}
		else if([chosenTitle isEqualToString:@"Twittelator Pro"]){
			url = [NSString stringWithFormat:@"twit:///post?message=%20&isDirect=0&replyToScreenName=%@",twitterView.twitterUserName];
		}
		else if([chosenTitle isEqualToString:@"Twitterriffic"]){
			url = [NSString stringWithFormat:@"twitterrific:///post?message=%@",atUsername];
		}
		
		[AppDelegate callExternalApplication:chosenTitle withURL:url];
	}
}

@end
