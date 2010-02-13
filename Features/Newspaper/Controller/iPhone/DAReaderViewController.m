//
//  MainViewController.m
//  DAReader
//
//  Created by Jared Crawford on 6/27/09.
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

#import "DAReaderViewController.h"
#import "FTUtils.h"

@implementation DAReaderViewController


@synthesize newsEngine;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


-(void)viewDidAppear:(BOOL)animated{
	NSError *anError;
	[[GANTracker sharedTracker] trackPageview:@"/Main/DAReader" withError:&anError];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return theNewspaperView;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	navBar = self.navigationController.navigationBar;
	
	theDatePickerSuperView.frame = CGRectMake(0, self.view.frame.size.height, theDatePickerSuperView.frame.size.width, theDatePickerSuperView.frame.size.height);
	theDatePicker.maximumDate = [NSDate date];
	theDatePicker.date = [NSDate date];
	theDatePickerToolbar.tintColor = [UIColor WVUBlueColor];
	theDatePickerSuperView.backgroundColor = [UIColor clearColor];
	
	theToolbar.tintColor = [UIColor WVUBlueColor];
	theNewspaperView.contentMode = UIViewContentModeScaleAspectFit;
	theScrollView.contentSize = CGSizeMake(theNewspaperView.frame.size.width, theNewspaperView.frame.size.height);
	[theScrollView addSubview:theNewspaperView];
	theScrollView.maximumZoomScale = 6.0;
	theScrollView.minimumZoomScale = 1;
	theScrollView.alwaysBounceVertical = YES;
	theScrollView.alwaysBounceHorizontal = YES;
	theScrollView.clipsToBounds = YES;
	theScrollView.bouncesZoom = YES;
	//theScrollView.userInteractionEnabled = NO;
	
	theScrollView.backgroundColor = [UIColor blackColor];
	theNewspaperView.backgroundColor = [UIColor blackColor];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Calendar.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(pickDate)] autorelease];
	
	self.newsEngine = [[[NewspaperEngine alloc] initWithDelegate:self] autorelease];
	[newsEngine downloadPagesForDate:theDatePicker.date];
	
	
}

-(void)goToTodaysDate{
	[theDatePicker setDate:[NSDate date]];
	[self performSelector:@selector(pickerDateChanged) withObject:nil afterDelay:.5];
}

-(void)pickDate{
	//
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:.7];
	
	if(theDatePickerSuperView.frame.origin.y == self.view.frame.size.height - 260){
		theDatePickerSuperView.frame=  CGRectMake(0,self.view.frame.size.height, theDatePickerSuperView.frame.size.width, theDatePickerSuperView.frame.size.height);
	}
	else{
		theDatePickerSuperView.frame = CGRectMake(0, self.view.frame.size.height - 260, theDatePickerSuperView.frame.size.width, theDatePickerSuperView.frame.size.height);
	}
	
	[UIView commitAnimations];
	
}


-(IBAction)pickerDateChanged{
	currentPage = 1;
	[self disableUserInteraction];
	theScrollView.zoomScale = 1;
	theNewspaperView.image = nil;
	self.navigationItem.title = @"The DA";
	[newsEngine downloadPagesForDate:theDatePicker.date];
}

-(void)disableUserInteraction{
	//
	theNewspaperView.userInteractionEnabled = NO;
	theScrollView.userInteractionEnabled = NO;
	pageNumLabel.text = @"";
	forwardButton.enabled = NO;
	backButton.enabled = NO;
}

-(void)enableUserInteraction{
	//
	theNewspaperView.userInteractionEnabled = YES;
	theScrollView.userInteractionEnabled = YES;
	theScrollView.multipleTouchEnabled = YES;
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



-(IBAction) nextPage{
	//
	if(currentPage < [newsEngine.downloadedPages count]){
		currentPage++;
	}
	else{
		currentPage = 1;
	}
	[self displayPage:currentPage asNext:YES];	
	
}



-(IBAction)previousPage{
	//
	if(currentPage > 1){
		currentPage--;
	}
	else{
		currentPage = [newsEngine.downloadedPages count];
	}
	[self displayPage:currentPage asNext:NO];	
}



-(void)displayPage:(int)pageNum asNext:(BOOL)isANextPage{

	
	UIImage *thePage = [newsEngine.downloadedPages objectAtIndex:(pageNum-1)];
	
	[UIView beginAnimations:nil context:thePage];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:1];
	
	if(isANextPage){
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:theScrollView cache:NO];
	}
	else{
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:theScrollView cache:NO];
	}
	theNewspaperView.image = thePage;
	theScrollView.zoomScale = 1;
	pageNumLabel.text = [NSString stringWithFormat:@"Page %d", currentPage];
	
	[UIView commitAnimations];
	[self nextPageIsAvailable];
	[self previousPageIsAvailable];
}


-(void)nextPageIsAvailable{
	if(([newsEngine.downloadedPages count] == 0)&&(![newsEngine isStillDownloading])){
		forwardButton.enabled = NO;
		[nextPageLoading stopAnimating];
	}
	else if(([newsEngine.downloadedPages count] == currentPage)&&([newsEngine isStillDownloading])){
		forwardButton.enabled = NO;
		[nextPageLoading startAnimating];
	}
	else{
		forwardButton.enabled = YES;
		[nextPageLoading stopAnimating];
	}
	
	
}

-(void)previousPageIsAvailable{
	if(([newsEngine.downloadedPages count] == 0)&&(![newsEngine isStillDownloading])){
		backButton.enabled = NO;
		[previousPageLoading stopAnimating];
	}
	else if((1 == currentPage)&&([newsEngine isStillDownloading])){
		backButton.enabled = NO;
		[previousPageLoading startAnimating];
	}
	else{
		backButton.enabled = YES;
		[previousPageLoading stopAnimating];
	}
}

-(void)newDataAvailable{
	if([newsEngine.downloadedPages count] == 1){
		theNewspaperView.hidden = YES;
		theNewspaperView.image = [newsEngine.downloadedPages objectAtIndex:0];
		[(UIView *)theNewspaperView popIn:.5 delegate:nil];
		pageNumLabel.text = @"Page 1";
		currentPage = 1;
		
	}
	[self enableUserInteraction];
	[self previousPageIsAvailable];
	[self nextPageIsAvailable];
}

@end
