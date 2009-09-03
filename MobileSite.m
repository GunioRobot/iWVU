//
//  MobileSite.m
//  iWVU
//
//  Created by Jared Crawford on 8/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MobileSite.h"
#import "iWVUAppDelegate.h"

@implementation MobileSite

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *websiteString = @"http://m.wvu.edu";
	NSURL *websiteURL = [NSURL URLWithString:websiteString];
	NSURLRequest *websiteRequest = [NSURLRequest requestWithURL:websiteURL];
	[theWebView loadRequest:websiteRequest];
	
	
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	//"catch all" error for now
	
	iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	UINavigationController *navController = AppDelegate.navigationController;
	[navController popViewControllerAnimated:YES];
	
	NSString *ErrorMessage = [NSString stringWithFormat: @"%@ Would you like to reload the page?", [error localizedDescription]];
	UIAlertView *err = [[UIAlertView alloc] initWithTitle:nil message:ErrorMessage delegate:nil cancelButtonTitle:@"No" otherButtonTitles:nil];//@"Yes"];
	[err show];
	[err release];
	
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
}


- (void)dealloc {
    [super dealloc];
}


@end
