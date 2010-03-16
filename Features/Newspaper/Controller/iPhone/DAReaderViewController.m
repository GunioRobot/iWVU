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
#import "FTAnimation+UIView.h"

#define ZOOM_STEP 2.5

@implementation DAReaderViewController


@synthesize newsEngine;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}




- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	[newsEngine cancelDownloads];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return theNewspaperView;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	navBar = self.navigationController.navigationBar;
	
	UIImage *flyingWVTwitter = [UIImage imageNamed:@"DANameLogo.png"];
	self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:flyingWVTwitter] autorelease];
	
	
	theNewspaperView = [[TapDetectingImageView alloc] initWithFrame:theScrollView.frame];
	[theScrollView addSubview:theNewspaperView];
	theNewspaperView.delegate = self;
	
	haveDisplayedPage1 = NO;
	
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

	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint {
    // double tap zooms in
    float newScale = [theScrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [theScrollView zoomToRect:zoomRect animated:YES];
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
    // two-finger tap zooms out
    float newScale = [theScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [theScrollView zoomToRect:zoomRect animated:YES];
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
	if(emptyView){
		[emptyView removeFromSuperview];
		emptyView = nil;
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	currentPage = 1;
	haveDisplayedPage1 = NO;
	[self disableUserInteraction];
	theScrollView.zoomScale = 1;
	theNewspaperView.image = nil;
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
	if(currentPage < [newsEngine numberOfPagesForDate:theDatePicker.date]){
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
		currentPage = [newsEngine numberOfPagesForDate:theDatePicker.date];
	}
	[self displayPage:currentPage asNext:NO];	
}



-(void)displayPage:(int)pageNum asNext:(BOOL)isANextPage{

	
	UIImage *thePage = [newsEngine getPage:pageNum forDate:theDatePicker.date];
	
	[UIView beginAnimations:@"flipPage" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:1];
	
	if(isANextPage){
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:theScrollView cache:YES];
	}
	else{
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:theScrollView cache:YES];
	}
	theNewspaperView.image = thePage;
	theScrollView.zoomScale = 1;
	pageNumLabel.text = [NSString stringWithFormat:@"Page %d", currentPage];
	
	[UIView commitAnimations];
	[self nextPageIsAvailable];
	[self previousPageIsAvailable];
}


-(void)nextPageIsAvailable{
	if(([newsEngine numberOfPagesForDate:theDatePicker.date] == 0)&&(![newsEngine isStillDownloading])){
		forwardButton.enabled = NO;
		[nextPageLoading stopAnimating];
	}
	else if(([newsEngine numberOfPagesForDate:theDatePicker.date] == currentPage)&&([newsEngine isStillDownloading])){
		forwardButton.enabled = NO;
		[nextPageLoading startAnimating];
	}
	else{
		forwardButton.enabled = YES;
		[nextPageLoading stopAnimating];
	}
	
	
}

-(void)previousPageIsAvailable{
	if(([newsEngine numberOfPagesForDate:theDatePicker.date] == 0)&&(![newsEngine isStillDownloading])){
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
	if(!haveDisplayedPage1){
		if([newsEngine numberOfPagesForDate:theDatePicker.date] > 0){
			theNewspaperView.hidden = YES;
			theNewspaperView.image = [newsEngine getPage:1 forDate:theDatePicker.date];
			[(UIView *)theNewspaperView popIn:.5 delegate:nil];
			pageNumLabel.text = @"Page 1";
			currentPage = 1;
			haveDisplayedPage1 = YES;
		}
		else{
			emptyView = [[TKEmptyView alloc] initWithFrame:self.view.frame emptyViewImage:TKEmptyViewImageChatBubble title:@"Edition Unavailable" subtitle:@"Choose a different edition."];
			emptyView.subtitle.numberOfLines = 2;
			emptyView.subtitle.lineBreakMode = UILineBreakModeWordWrap;
			emptyView.subtitle.font = [emptyView.subtitle.font fontWithSize:12];
			emptyView.title.font = [emptyView.title.font fontWithSize:22];
			emptyView.subtitle.clipsToBounds = NO;
			emptyView.title.clipsToBounds = NO;
			[self.view addSubview:emptyView];
			[self.view bringSubviewToFront:emptyView];
			[self.view bringSubviewToFront:theDatePickerSuperView];
			[emptyView release];
		}
	}
	[self enableUserInteraction];
	[self previousPageIsAvailable];
	[self nextPageIsAvailable];
	if([newsEngine isStillDownloading]){
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
	else {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}

}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [theScrollView frame].size.height / scale;
    zoomRect.size.width  = [theScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

@end
