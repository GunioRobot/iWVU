//
//  iWVUAppDelegate.m
//  iWVU
//
//  Created by Jared Crawford on 6/9/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
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
#import "MainTableView.h"
#import "WebViewController.h"


@implementation iWVUAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	
	
	navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:.199 blue:.3984 alpha:1];
	
	
	
	
	
	MainTableView *theFirstPage = [[MainTableView alloc] initWithStyle:UITableViewStyleGrouped];
	
	theFirstPage.navigationItem.title = @"iWVU";
	UIImage *flyingWV = [UIImage imageNamed:@"WVUTitle.png"];
	theFirstPage.navigationItem.titleView = [[[UIImageView alloc] initWithImage:flyingWV] autorelease];
	theFirstPage.navigationItem.hidesBackButton = YES;
	
	
	[navigationController pushViewController:theFirstPage animated:NO];
	
	[theFirstPage release];
	
	
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
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
	
	if(isOdd){
		if(indexPath.row == 0){
			if([tableView numberOfRowsInSection:indexPath.section] == 1){
				return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUSingleBlue.png"]] autorelease];
			}
			else{
				return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUTopBlue.png"]] autorelease];
			}
		}
		else if(indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1)){
			return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUBottomBlue.png"]] autorelease];
		}
		else {
			return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUMiddleBlue.png"]] autorelease];
		}
	}
	else{
		if(indexPath.row == 0){
			if([tableView numberOfRowsInSection:indexPath.section] == 1){
				return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUSingleYellow.png"]] autorelease];
			}
			else{
				return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUTopYellow.png"]] autorelease];
			}
		}
		else if(indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1)){
			return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUBottomYellow.png"]] autorelease];
		}
		else {
			return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUMiddleYellow.png"]] autorelease];
		}
	}
}


-(UIImageView *)getCellSelectedBackgroundForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
	//
	
	
	BOOL isOdd = [self isIndexPath:indexPath forTableView:tableView];
	
	if(isOdd){
		if(indexPath.row == 0){
			if([tableView numberOfRowsInSection:indexPath.section] == 1){
				return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUSingleYellow.png"]] autorelease];
			}
			else{
				return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUTopYellow.png"]] autorelease];
			}
		}
		else if(indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1)){
			return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUBottomYellow.png"]] autorelease];
		}
		else {
			return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUMiddleYellow.png"]] autorelease];
		}
	}
	else{
		if(indexPath.row == 0){
			if([tableView numberOfRowsInSection:indexPath.section] == 1){
				return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUSingleBlue.png"]] autorelease];
			}
			else{
				return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUTopBlue.png"]] autorelease];
			}
		}
		else if(indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1)){
			return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUBottomBlue.png"]] autorelease];
		}
		else {
			return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WVUMiddleBlue.png"]] autorelease];
		}
	}
}



-(UITableViewCell *)configureTableViewCell:(UITableViewCell *)cell inTableView:(UITableView *)table forIndexPath:(NSIndexPath *)indexPath{
	cell.backgroundView = [self getCellBackgroundForTableView:table atIndexPath:indexPath];
	cell.selectedBackgroundView = [self getCellSelectedBackgroundForTableView:table atIndexPath:indexPath];
	BOOL isOdd = [self isIndexPath:indexPath forTableView:table];
	if(!isOdd){
		cell.detailTextLabel.textColor = [UIColor blackColor];
		cell.textLabel.highlightedTextColor = [UIColor colorWithRed:1 green:.8 blue:0 alpha:1];
		cell.textLabel.textColor = [UIColor colorWithRed:0 green:.2 blue:.4 alpha:1];
	}
	else{
		cell.detailTextLabel.textColor = [UIColor whiteColor];
		cell.textLabel.textColor = [UIColor colorWithRed:1 green:.8 blue:0 alpha:1];
		cell.textLabel.highlightedTextColor = [UIColor colorWithRed:0 green:.2 blue:.4 alpha:1];
	}
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	//table.backgroundColor = [UIColor colorWithRed:1 green:.8 blue:0 alpha:1];
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

-(void)loadWebViewWithURL:(NSString *)theURL andTitle:(NSString *)theTitle{
	WebViewController *theWebView = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
	theWebView.navigationItem.title = theTitle;
	((UILabel *)theWebView.navigationItem.titleView).textColor = [UIColor colorWithRed:1 green:.8 blue:0 alpha:1];
	theWebView.URLtoLoad = theURL;
	[self.navigationController pushViewController:theWebView animated:YES];
	[theWebView release];
	
}


@end

