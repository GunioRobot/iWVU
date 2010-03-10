//
//  iWVUAppDelegate.m
//  iWVU
//
//  Created by Jared Crawford on 6/9/09.
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


#import <MessageUI/MessageUI.h>

#import "iWVUAppDelegate.h"
#import "RootViewController.h"

#import "MainScreen.h"

#import "TTDefaultStyleSheet+NavigationBarTintColor.h"


#define IMAGE_CAP_LEFT 30
#define IMAGE_CAP_TOP 25 


@implementation iWVUAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	
	
	navigationController.navigationBar.tintColor = [UIColor WVUBlueColor];
	
	
	
	
	
	//MainTableView *theFirstPage = [[MainTableView alloc] initWithStyle:UITableViewStyleGrouped];
	MainScreen *theFirstPage = [[MainScreen alloc] init];
	
	
	theFirstPage.navigationItem.title = @"iWVU";
	UIImage *flyingWV = [UIImage imageNamed:@"WVUTitle.png"];
	theFirstPage.navigationItem.titleView = [[[UIImageView alloc] initWithImage:flyingWV] autorelease];
	theFirstPage.navigationItem.hidesBackButton = YES;
	
	
	[navigationController pushViewController:theFirstPage animated:NO];
	
	[theFirstPage release];
	
	
}


+(void)initialize{
	[[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-5972486-3" dispatchPeriod:5 delegate:self];
	NSError *anError;
	[[GANTracker sharedTracker] trackPageview:@"/AppLaunched" withError:&anError];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	[[GANTracker sharedTracker] stopTracker];
}


-(BOOL)isIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView{
	
	//////////////////
	// Alternate Rows
	//////////////////
	
	/*
	 int i = 0;
	 for(int sect = 0; sect<indexPath.section;sect++){
	 i += [tableView.dataSource tableView:tableView numberOfRowsInSection:sect];
	 }
	 i += indexPath.row;
	 if( i%2 == 0){
	 return NO;
	 }
	 return YES;
	 */
	
	
	//////////////////
	// Alternate Sections
	//////////////////
	
	
	
	if(indexPath.section %2 == 0){
		return YES;
	}
	return NO;
	
	
	//////////////////
	// Just Use One
	//////////////////
	
	
	return YES;
	
}



-(UIImageView *)getCellBackgroundForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
	BOOL isOdd = [self isIndexPath:indexPath forTableView:tableView];
	NSString *imageName;
	
	
	
	if(isOdd){
		if(indexPath.row == 0){
			if([tableView numberOfRowsInSection:indexPath.section] == 1){
				imageName = @"WVUSingleBlue.png";
			}
			else{
				imageName = @"WVUTopBlue.png";
			}
		}
		else if(indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1)){
			imageName = @"WVUBottomBlue.png";
		}
		else {
			imageName = @"WVUMiddleBlue.png";
		}
	}
	else{
		if(indexPath.row == 0){
			if([tableView numberOfRowsInSection:indexPath.section] == 1){
				imageName = @"WVUSingleYellow.png";
			}
			else{
				imageName = @"WVUTopYellow.png";
			}
		}
		else if(indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1)){
			imageName = @"WVUBottomYellow.png";
		}
		else {
			imageName = @"WVUMiddleYellow.png";
		}
	}
	
	UIImage *anImage = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:IMAGE_CAP_LEFT topCapHeight:IMAGE_CAP_TOP];
	return [[[UIImageView alloc] initWithImage:anImage] autorelease];
}


-(UIImageView *)getCellSelectedBackgroundForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
	//
	
	
	BOOL isOdd = [self isIndexPath:indexPath forTableView:tableView];
	
	NSString *imageName;
	
	
	if(isOdd){
		if(indexPath.row == 0){
			if([tableView numberOfRowsInSection:indexPath.section] == 1){
				imageName = @"WVUSingleYellow.png";
			}
			else{
				imageName = @"WVUTopYellow.png";
			}
		}
		else if(indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1)){
			imageName = @"WVUBottomYellow.png";
		}
		else {
			imageName = @"WVUMiddleYellow.png";
		}
	}
	else{
		if(indexPath.row == 0){
			if([tableView numberOfRowsInSection:indexPath.section] == 1){
				imageName = @"WVUSingleBlue.png";
			}
			else{
				imageName = @"WVUTopBlue.png";
			}
		}
		else if(indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1)){
			imageName = @"WVUBottomBlue.png";
		}
		else {
			imageName = @"WVUMiddleBlue.png";
		}
	}
	
	UIImage *anImage = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:IMAGE_CAP_LEFT topCapHeight:IMAGE_CAP_TOP];
	return [[[UIImageView alloc] initWithImage:anImage] autorelease];
}



-(UITableViewCell *)configureTableViewCell:(UITableViewCell *)cell inTableView:(UITableView *)table forIndexPath:(NSIndexPath *)indexPath{
	cell.backgroundView = [self getCellBackgroundForTableView:table atIndexPath:indexPath];
	cell.selectedBackgroundView = [self getCellSelectedBackgroundForTableView:table atIndexPath:indexPath];
	//cell.textLabel.font = [NSFont 
	BOOL isOdd = [self isIndexPath:indexPath forTableView:table];
	if(!isOdd){
		cell.detailTextLabel.textColor = [UIColor blackColor];
		cell.textLabel.highlightedTextColor = [UIColor WVUGoldColor];
		cell.textLabel.textColor = [UIColor WVUBlueColor];
	}
	else{
		cell.detailTextLabel.textColor = [UIColor whiteColor];
		cell.textLabel.textColor = [UIColor WVUGoldColor];
		cell.textLabel.highlightedTextColor = [UIColor WVUBlueColor];
	}
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	return cell;
}

-(void)composeEmailTo:(NSString *)to withSubject:(NSString *)subject andBody:(NSString *)body{
	//
	if([MFMailComposeViewController canSendMail]){
		MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
		if(to!=nil){
			[mailView setToRecipients:[NSArray arrayWithObject:to]];
		}
		[mailView setSubject:subject];
		[mailView setMessageBody:body isHTML:YES];
		[navigationController pushViewController:mailView.topViewController animated:YES];
		mailView.mailComposeDelegate = self;
		[mailView release];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
	[navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

-(void)loadWebViewWithURL:(NSString *)theURL{
	if(theURL){
		TTWebController *theWebView = [[TTWebController alloc] init];
		theWebView.navigationBarTintColor = [UIColor WVUBlueColor];
		NSURL *aURL = [NSURL URLWithString:theURL]; 
		[theWebView openURL:aURL];
		[self.navigationController pushViewController:theWebView animated:YES];
		[theWebView release];
	}
}


-(void)callPhoneNumber:(NSString *)phoneNum{
	NSString *deviceModel = [UIDevice currentDevice].model;
	if ([deviceModel isEqualToString:@"iPhone"]) {
		while ([phoneNum characterAtIndex:0] == ' ') {
			phoneNum = [phoneNum substringFromIndex:1];
		}
		
		UIAlertView *err = [[UIAlertView alloc] initWithTitle:phoneNum message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call",nil];
		err.tag = 1;
		[err show];
		[err release];
	}
	else{
		NSString *message = [NSString stringWithFormat:@"The %@ does not support phone calls. You may call %@ from a phone.", deviceModel, phoneNum];
		UIAlertView *err = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[err show];
		[err release];
	}
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (alertView.tag == 1) {
		if ([@"Call" isEqualToString:[alertView buttonTitleAtIndex:buttonIndex]] ) {
			//turn a human readable number to a tel:XXXXXXXXXX format
			
			NSString *phoneNum = alertView.title;
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"(" withString:@""];
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@")" withString:@""];
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"ext." withString:@","];
			NSString *phoneNumWithPre = [NSString stringWithFormat:@"tel:%@", phoneNum];
			NSURL *phoneURL = [NSURL URLWithString:phoneNumWithPre];
			[[UIApplication sharedApplication] openURL:phoneURL];
		}
	}
}


-(void)serviceAttemptFailedForApp:(NSString *)application{
	NSString *message = [NSString stringWithFormat:@"%@ is not responding. This typically means the application is not installed.", application];
	UIAlertView *err = [[UIAlertView alloc] initWithTitle:application message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[err show];
	[err release];
}

-(void)callExternalApplication:(NSString *)application withURL:(NSString *)url{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	[self performSelector:@selector(serviceAttemptFailedForApp:) withObject:application afterDelay:0.5f]; 
}



+ (void)trackerDispatchDidComplete:(GANTracker *)tracker
                  eventsDispatched:(NSUInteger)eventsDispatched
              eventsFailedDispatch:(NSUInteger)eventsFailedDispatch{
	/*
	NSString *message = [NSString stringWithFormat:@"Sucesses:%d\nErrors:%d",eventsDispatched, eventsFailedDispatch];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Google Analytics" message:message delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
	 */
}



@end

