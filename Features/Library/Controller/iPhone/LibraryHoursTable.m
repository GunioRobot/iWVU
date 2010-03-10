//
//  LibraryHoursTable.m
//  iWVU
//
//  Created by Jared Crawford on 6/12/09.
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

#import "LibraryHoursTable.h"


@implementation LibraryHoursTable

@synthesize theHoursWebView;


-(void)loadWebViewData{
	NSString *FilePath =  NSTemporaryDirectory();
	FilePath = [FilePath stringByAppendingPathComponent:@"LibraryHoursTable.html"];
	[theHoursWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:FilePath]]];
	theHoursWebView.hidden = NO;
	[theSpinner stopAnimating];
}


-(void)viewDidAppear:(BOOL)animated{
	NSError *anError;
	[[GANTracker sharedTracker] trackPageview:@"/Main/Library/Hours" withError:&anError];
}


-(void)getHoursForLibrary{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//
	NSString *html = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.libraries.wvu.edu/"]];
	if (html != nil){
		
		NSArray *lines=[html componentsSeparatedByString:@"\n"];
		NSEnumerator *enumer = [lines objectEnumerator];
		
		NSString *nextStr = [enumer nextObject];
		
		NSString *finalData = @"<html><head><style type=\"text/css\">";
		finalData = [finalData stringByAppendingString:@"a {text-decoration:none; color: black;}body{background-image:url('"];
		finalData = [finalData stringByAppendingString:[[NSBundle mainBundle] pathForResource:@"LibraryTableBack" ofType:@"png"]];
		finalData = [finalData stringByAppendingString:@"');background-repeat:repeat-y;}#hoursTable{border: none;padding: 0;width: 305px;height: 150px; margin: 0;padding: 0;} #hoursTable td { padding: 3px;}.libraryName {width: 60%;text-align: left;vertical-align: top;}.libraryHours {width: 40%;text-align: right;}.hoursOdd {background-color: #FAFAFA;margin: 0;}.hoursEven {margin: 0;background-color: #D8D8D8;}"];
		
		finalData = [finalData stringByAppendingString:@"</style></head><body><table id=\"hoursTable\" cellspacing=\"0\">"];
		
		while((nextStr != nil) && ([[nextStr stringByReplacingOccurrencesOfString:@"\t" withString:@""] hasPrefix:@"<tr><td class=\"libraryName"] == NO)){
			nextStr = [enumer nextObject];
		}
		
		nextStr = [nextStr stringByReplacingOccurrencesOfString:@"/images/hpmisc/clock.gif" withString:@"http://www.libraries.wvu.edu/images/hpmisc/clock.gif"];
		//nextStr = [nextStr stringByReplacingOccurrencesOfString:@"/images/hpmisc/clock.gif" withString:@""];
		
		
		finalData = [finalData stringByAppendingString:nextStr];
		finalData = [finalData stringByAppendingString:@"</table></body></html>"];
		
		NSString *FilePath =  NSTemporaryDirectory();
		FilePath = [FilePath stringByAppendingPathComponent:@"LibraryHoursTable.html"];
		[finalData writeToFile:FilePath atomically:YES encoding:NSUnicodeStringEncoding error:NULL];
	}
	else{
		/*UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must have an internet connection to view the current Library Hours" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		 [err show];
		 [err release];
		 */
		NSString *finalData = @"<html><head><style type=\"text/css\">";
		finalData = [finalData stringByAppendingString:@"a {text-decoration:none; color: black;}body{background-image:url('"];
		finalData = [finalData stringByAppendingString:[[NSBundle mainBundle] pathForResource:@"LibraryTableBack" ofType:@"png"]];
		finalData = [finalData stringByAppendingString:@"');background-repeat:repeat-y;}"];
		finalData = [finalData stringByAppendingString:@"</style></head><body>"];
		finalData = [finalData stringByAppendingString:@"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"];
		finalData = [finalData stringByAppendingString:@"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"];
		finalData = [finalData stringByAppendingString:@"&nbsp;&nbsp;&nbsp;"];
		finalData = [finalData stringByAppendingString:@"Network Data Unavailable"];
		finalData = [finalData stringByAppendingString:@"</body></html>"];
		NSString *FilePath =  NSTemporaryDirectory();
		FilePath = [FilePath stringByAppendingPathComponent:@"LibraryHoursTable.html"];
		[finalData writeToFile:FilePath atomically:YES encoding:NSUnicodeStringEncoding error:NULL];
	}
	NSThread *currentThread = [NSThread currentThread];
	if([currentThread isCancelled] == NO){
		[self performSelectorOnMainThread:@selector(loadWebViewData) withObject:nil waitUntilDone:NO];
	}
	[pool release];
}






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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[theSpinner startAnimating];
	
	aThread = [[NSThread alloc] initWithTarget:self selector:@selector(getHoursForLibrary) object:nil];
	[aThread start];
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


- (void)viewWillDisappear:(BOOL)animated {
	[aThread cancel];
	[aThread release];
}
	

- (void)dealloc {
    [super dealloc];
}


@end
