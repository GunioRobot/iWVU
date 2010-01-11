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


@implementation DAReaderViewController


@synthesize baseURL;
@synthesize editionDate;
@synthesize mostRecentRequest;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


/*
 //Legacy code for a flipside view controller. Kept for archival sake.

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

*/


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */


-(void)viewDidAppear:(BOOL)animated{
	NSError *anError;
	[[GANTracker sharedTracker] trackPageview:@"/Main/DAReader" withError:&anError];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	navBar = AppDelegate.navigationController.navigationBar;
	
	theDatePickerSuperView.frame = CGRectMake(0, self.view.frame.size.height, theDatePickerSuperView.frame.size.width, theDatePickerSuperView.frame.size.height);
	theDatePicker.maximumDate = [NSDate date];
	theDatePicker.date = [NSDate date];
	theDatePickerToolbar.tintColor = [UIColor WVUBlueColor];
	theDatePickerSuperView.backgroundColor = [UIColor clearColor];
	
	theToolbar.tintColor = [UIColor WVUBlueColor];
	theNewspaperView.contentMode = UIViewContentModeScaleAspectFit;
	theScrollView.contentSize = CGSizeMake(theNewspaperView.frame.size.width, theNewspaperView.frame.size.height);
	theScrollView.maximumZoomScale = 6.0;
	theScrollView.minimumZoomScale = 1;
	theScrollView.alwaysBounceVertical = YES;
	theScrollView.alwaysBounceHorizontal = YES;
	theScrollView.clipsToBounds = YES;
	theScrollView.bouncesZoom = YES;
	theScrollView.userInteractionEnabled = NO;
	
	theScrollView.backgroundColor = [UIColor blackColor];
	theNewspaperView.backgroundColor = [UIColor blackColor];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Calendar.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(pickDate)] autorelease];
	
	
	
	self.baseURL = @"http://www.wvu.edu/~wvuda/";
	self.editionDate = [[[NSDate date] description] substringToIndex:10]; 
	
	[self loadEdition];
	
	isNextPageAsOposedToPrevious = YES;
	
	
	//NSData *Page 1 = [NSData dataWithContentsOfURL:page1String];
	
}

-(void)goToTodaysDate{
	//
	[theDatePicker setDate:[NSDate date]];
	[self performSelector:@selector(pickerDateChanged) withObject:nil afterDelay:.5];
}

-(void)loadEdition{
	[theSpinner startAnimating];
	
	noEdition = NO;
	
	
	//Make Variable
	numOfPagesTotal = 20;
	currentPage = 1;
	pageNumLabel.text = @"Page 1";
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for(int i=1;i<=numOfPagesTotal;i++){
		NSString *myPath = NSTemporaryDirectory();
		myPath = [myPath stringByAppendingPathComponent:@"Page"];
		myPath = [myPath stringByAppendingFormat:@"%d.jpg",i,nil];
		[fileManager removeItemAtPath:myPath error:NULL];
	}
	
	
	
	
	NSNumber *numberOfPages = [NSNumber numberWithInt:numOfPagesTotal];
	NSNumber *firstPage= [NSNumber numberWithInt:1];
	NSNumber *loadNow = [NSNumber numberWithInt:1];//yes
	NSNumber *keepLoading = [NSNumber numberWithInt:1];//yes
	self.mostRecentRequest = [NSDate date];
	NSDate *timeStamp = mostRecentRequest;
	
	NSArray *theDataForThread = [NSArray arrayWithObjects:baseURL, editionDate, firstPage, numberOfPages, loadNow, keepLoading, timeStamp, nil];
	
	[self performSelectorOnMainThread:@selector(determineNextAndPreviousPageAvailability:) withObject:timeStamp waitUntilDone:NO];
	
	[NSThread detachNewThreadSelector:@selector(getNewspaperDataWithArray:) toTarget:self withObject:theDataForThread];
	
	
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
	
	numOfPagesTotal = 20;
	theScrollView.zoomScale = 1;
	theNewspaperView.image = nil;
	theScrollView.userInteractionEnabled = NO;
	
	self.editionDate = [[theDatePicker.date description] substringToIndex:10];
	if([editionDate isEqualToString:[[[NSDate date] description] substringToIndex:10]]){
		self.navigationItem.title = @"Today's DA";
	}
	else{
		self.navigationItem.title = [@"The DA " stringByAppendingString:editionDate];
	}
	[self loadEdition];
	
}

-(void)getNewspaperDataWithArray:(NSArray *)URLstrPageNumAndLoadNow{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	
	//[self performSelectorOnMainThread:@selector(determineNextAndPreviousPageAvailability) withObject:nil waitUntilDone:NO];
	
	//Unpack Array
	NSString *arrbaseURL = [URLstrPageNumAndLoadNow objectAtIndex:0];
	NSString *arreditionDate = [URLstrPageNumAndLoadNow objectAtIndex:1];
	int pageNum = [(NSNumber *)[URLstrPageNumAndLoadNow objectAtIndex:2] intValue];
	int numberOfPages = [(NSNumber *)[URLstrPageNumAndLoadNow objectAtIndex:3] intValue];
	BOOL loadNow = NO;
	if(1==[(NSNumber *)[URLstrPageNumAndLoadNow objectAtIndex:4] intValue]){
		loadNow = YES;
	}
	BOOL keepLoading = NO;
	if(1==[(NSNumber *)[URLstrPageNumAndLoadNow objectAtIndex:5] intValue]){
		keepLoading = YES;
	}
	NSDate *timeStamp = [URLstrPageNumAndLoadNow objectAtIndex:6];
	
	NSString *theURLstring = [NSString stringWithFormat:@"%@%@/Page%@%d.jpg",arrbaseURL,arreditionDate,@"%20",pageNum];
	
	NSURL *theURL = [NSURL URLWithString:theURLstring];
	NSString *localURLstr = NSTemporaryDirectory();
	NSString *pageString = [@"Page" stringByAppendingFormat:@"%d.jpg", pageNum];
	localURLstr = [localURLstr stringByAppendingPathComponent:pageString];
	//local URLstr = temp/page1.jpg
	NSData *imageData;
	if([timeStamp isEqualToDate:mostRecentRequest]){
		//NSLog(@"%@",theURLstring);
		NSError *anError;
		imageData= [NSData dataWithContentsOfURL:theURL options:0 error:&anError];
	}
	UIImage *aTestPage = [UIImage imageWithData:imageData];
	if(aTestPage == nil){ 
		if([timeStamp isEqualToDate:mostRecentRequest]){
			// write an error screen to localURLstr	
			numberOfPages = pageNum;
			if(pageNum == 1){
				numOfPagesTotal = pageNum;
				NSURL *errorFileURL = [NSURL fileURLWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"DAError.png"]];
				imageData = [NSData dataWithContentsOfURL:errorFileURL];
				[self performSelectorOnMainThread:@selector(disableUserInteraction) withObject:nil waitUntilDone:YES];
				
				noEdition = YES;
			}
			else{
				numOfPagesTotal = pageNum-1;
			}
		}
	}
	else if([timeStamp isEqualToDate:mostRecentRequest]){
		[self performSelectorOnMainThread:@selector(enableUserInteraction) withObject:nil waitUntilDone:YES];
	}
	
	
	if([timeStamp isEqualToDate:mostRecentRequest]){
		[imageData writeToFile:localURLstr atomically:YES];
	}
	
	
	if(loadNow && [timeStamp isEqualToDate:mostRecentRequest]){ //used only on the first run
		UIImage *thePage = [UIImage imageWithData:imageData];
		NSArray *pageReturnArray = [NSArray arrayWithObjects:thePage, timeStamp, nil];
		[self performSelectorOnMainThread:@selector(displayUIImage:) withObject:pageReturnArray waitUntilDone:NO];
	}
	
	//used to loop through all of the images on the first run, never again
	if((keepLoading)&&(pageNum < numberOfPages)&&[timeStamp isEqualToDate:mostRecentRequest]){
		NSNumber *arrnumberOfPages = [NSNumber numberWithInt:numberOfPages];
		NSNumber *arrpageNum= [NSNumber numberWithInt:(pageNum+1)];
		NSNumber *arrloadNow = [NSNumber numberWithInt:0];//no
		NSNumber *arrkeepLoading = [NSNumber numberWithInt:1];//yes
		
		NSArray *theDataForThread = [NSArray arrayWithObjects:arrbaseURL, arreditionDate,arrpageNum,arrnumberOfPages, arrloadNow, arrkeepLoading, timeStamp, nil];
		[NSThread detachNewThreadSelector:@selector(getNewspaperDataWithArray:) toTarget:self withObject:theDataForThread];
		
	}
	
	//this gets called by methods after the first run, it calls the animated load method
	if(!loadNow && !keepLoading){
		UIImage *thePage = [UIImage imageWithData:imageData];
		[self performSelectorOnMainThread:@selector(fileIsReadyToLoadAnimated:) withObject:thePage waitUntilDone:NO];
	}
	
	
	[self performSelectorOnMainThread:@selector(determineNextAndPreviousPageAvailability:) withObject:timeStamp waitUntilDone:NO];
	
	[pool release];
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
	//forwardButton.enabled = YES;
	//backButton.enabled = YES;
}

-(void)displayUIImage:(NSArray *)thePageAndTimestamp{
	
	
	UIImage *thePage = [thePageAndTimestamp objectAtIndex:0];
	NSDate *timeStamp = [thePageAndTimestamp objectAtIndex:1];
	[self performSelectorOnMainThread:@selector(determineNextAndPreviousPageAvailability:) withObject:timeStamp waitUntilDone:NO];
		
	if([timeStamp isEqualToDate:mostRecentRequest]){
		theNewspaperView.image = thePage;
		[theSpinner stopAnimating];
	}
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
	self.baseURL = nil;
	self.editionDate = nil;
    [super dealloc];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return theNewspaperView;
}


-(IBAction) nextPage{
	//
	if(currentPage < numOfPagesTotal){
		currentPage++;
	}
	else{
		currentPage = 1;
	}
	isNextPageAsOposedToPrevious = YES;
	[self tryToLoadCurrentPageAnimated];	
	
}



-(IBAction)previousPage{
	//
	if(currentPage > 1){
		currentPage--;
	}
	else{
		currentPage = numOfPagesTotal;
	}
	isNextPageAsOposedToPrevious = NO;
	[self tryToLoadCurrentPageAnimated];	
}


-(void)tryToLoadCurrentPageAnimated{
	[theScrollView setZoomScale:1 animated:YES];
	[self performSelectorOnMainThread:@selector(determineNextAndPreviousPageAvailability:) withObject:nil waitUntilDone:NO];
	NSString *nextPageString = NSTemporaryDirectory();
	NSString *fileName = [NSString stringWithFormat:@"Page%d.jpg",currentPage];
	nextPageString = [nextPageString stringByAppendingPathComponent:fileName];
	NSData *imageData = [NSData dataWithContentsOfFile:nextPageString];
	UIImage *thePage = [UIImage imageWithData:imageData];
	if(thePage!=nil){
		[self fileIsReadyToLoadAnimated:thePage];
	}
	else{
		NSNumber *numberOfPages = [NSNumber numberWithInt:20];
		NSNumber *Pagenum= [NSNumber numberWithInt:currentPage];
		NSNumber *loadNow = [NSNumber numberWithInt:0];//no
		NSNumber *keepLoading = [NSNumber numberWithInt:0];//no
		//self.mostRecentRequest = [NSDate date];
		
		NSArray *theDataForThread = [NSArray arrayWithObjects:baseURL, editionDate, Pagenum, numberOfPages, loadNow, keepLoading, mostRecentRequest,nil];
		[NSThread detachNewThreadSelector:@selector(getNewspaperDataWithArray:) toTarget:self withObject:theDataForThread];
	}
}

-(void)fileIsReadyToLoadAnimated:(UIImage *)thePage{
	//animation block
	//page roll
	//load image
	//[self performSelectorOnMainThread:@selector(determineNextAndPreviousPageAvailability:) withObject:nil waitUntilDone:NO];
		
		[thePage retain];
		
		[UIView beginAnimations:nil context:thePage];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationWillStartSelector:@selector(switchImages:withPage:)];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:1];
		
		if(isNextPageAsOposedToPrevious){
			[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:theScrollView cache:NO];
		}
		else{
			[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:theScrollView cache:NO];
		}
		theNewspaperView.image = thePage;
		pageNumLabel.text = [NSString stringWithFormat:@"Page %d", currentPage];
		
		[UIView commitAnimations];
		
		[thePage release];
}


-(void)nextPageIsAvailable:(BOOL)isAvailable{
	//
	
	if(noEdition){
		forwardButton.enabled = NO;
		[nextPageLoading stopAnimating];
	}
	else 
	if(isAvailable){
		forwardButton.enabled = YES;
		[nextPageLoading stopAnimating];
	}
	else{
		forwardButton.enabled = NO;
		[nextPageLoading startAnimating];
	}
	
	
}

-(void)previousPageIsAvailable:(BOOL)isAvailable{
	//
	if(noEdition){
		backButton.enabled = NO;
		[previousPageLoading stopAnimating];
	}
	else if(isAvailable){
		backButton.enabled = YES;
		[previousPageLoading stopAnimating];
	}
	else{
		backButton.enabled = NO;
		[previousPageLoading startAnimating];
	}
}


-(void)determineNextAndPreviousPageAvailability:(NSDate *)timesStamp{
	//
	
	//[self performSelectorOnMainThread:@selector(determineNextAndPreviousPageAvailability) withObject:nil waitUntilDone:NO];
	
	if( [timesStamp isEqualToDate:mostRecentRequest] || timesStamp==nil){
		
		
		NSFileManager *fileMan = [NSFileManager defaultManager];
		NSString *path = NSTemporaryDirectory();
		int nextPageNum;
		if(currentPage < numOfPagesTotal){
			nextPageNum = currentPage+1;
		}
		else{
			nextPageNum = 1;
		}
		
		
		NSString *nextPageString = [@"Page" stringByAppendingFormat:@"%d.jpg", nextPageNum];
		nextPageString = [path stringByAppendingPathComponent:nextPageString];
		
		
		int previousPageNum;
		if(currentPage > 1){
			previousPageNum = currentPage-1;
		}
		else{
			previousPageNum = numOfPagesTotal;
		}
		NSString *previousPageString = [@"Page" stringByAppendingFormat:@"%d.jpg", previousPageNum];
		previousPageString = [path stringByAppendingPathComponent:previousPageString];
		
		
		BOOL nextIsAvailable = [fileMan fileExistsAtPath:nextPageString];
		BOOL previousIsAvailable = [fileMan fileExistsAtPath:previousPageString];
		
		[self nextPageIsAvailable:nextIsAvailable];
		[self previousPageIsAvailable:previousIsAvailable];
	}
	
}



@end
