//
//  WebViewController.m
//  iWVU
//
//  Created by Jared Crawford on 6/10/09.
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

#import "WebViewController.h"


@implementation WebViewController

@synthesize theToolbar;
@synthesize theWebView;
@synthesize spinner;
@synthesize forwardButton;
@synthesize backButton;
@synthesize URLtoLoad;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


-(void)viewDidAppear:(BOOL)animated{
	NSError *anError;
	[[GANTracker sharedTracker] trackPageview:@"/Browser" withError:&anError];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    theToolbar.tintColor = [UIColor WVUBlueColor];
	spinner.frame = CGRectMake(152, 6, spinner.frame.size.width, spinner.frame.size.height);
	[super viewDidLoad];
	[self loadURL:URLtoLoad];
	
	
	[self.theToolbar addSubview:spinner];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.spinner = nil;
}


- (void)dealloc {
	self.spinner = nil;
	
	
	
	
	self.theToolbar = nil;
	self.theWebView = nil;
	self.backButton = nil;
	self.forwardButton = nil;
	self.URLtoLoad = nil;
	
    [super dealloc];
}



-(void)loadURL:(NSString *)URL{
	NSURL *theURL;
	if([URL isEqualToString:@"Ask A Librarian"] == NO){
		theURL = [NSURL URLWithString:URL];
	}
	else{
		NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"AskALibrarianChat.html"];
		theURL = [NSURL fileURLWithPath:path];
	}
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL];
	[theWebView loadRequest:theRequest];
}



-(IBAction)backButtonPressed:(id)sender{
	//
	if(theWebView.canGoBack){
		[theWebView goBack];
	}
}



-(IBAction)reloadButtonPressed:(id)sender{
	//reload
	[theWebView reload];
}




-(IBAction)forwardButtonPressed:(id)sender{
	//if cangoforward go forward
	if(theWebView.canGoForward){
		[theWebView goForward];
	}
}




-(IBAction)actionButtonPressed:(id)sender{
	//open in safari option
	UIActionSheet *act =[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", @"Email link", nil];
	act.actionSheetStyle = UIActionSheetStyleDefault;
	[act showInView:self.view];
	[act release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	//
	NSString *butTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	
	if([@"Open in Safari" isEqualToString:butTitle]){
		[[UIApplication sharedApplication] openURL:[theWebView.request URL]];
	}
	else if([@"Email link" isEqualToString:butTitle]){
		[((iWVUAppDelegate *)[UIApplication sharedApplication].delegate) composeEmailTo:nil withSubject:nil andBody:[[theWebView.request URL] absoluteString]];
	}
	
}





- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The website has failed to load. Please check your internet connection and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
	//spinner start
	[spinner startAnimating];
}



- (void)webViewDidFinishLoad:(UIWebView *)webView{
	//spinner stop
	[spinner stopAnimating];
	
	if(theWebView.canGoBack == NO){
		backButton.enabled = NO;
	}
	else{
		backButton.enabled = YES;
	}
	
	if(theWebView.canGoForward == NO){
		forwardButton.enabled = NO;
	}
	else{
		forwardButton.enabled = YES;
	}	
	
	
}






@end
