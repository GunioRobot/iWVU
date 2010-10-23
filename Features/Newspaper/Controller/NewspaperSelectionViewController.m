    //
//  NewspaperSelectionViewController.m
//  iWVU
//
//  Created by Jared Crawford on 10/12/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "NewspaperSelectionViewController.h"
#import "Reachability.h"
#import "NSDate+Helper.h"

#define MAX_NUMBER_OF_DAYS_AGO_TO_SEARCH 7
#define NEWSPAPER_FINDING_TEXT @"Searching for the most recent edition"
#define NEWSPAPER_DATE_FORMAT @"MMM d, YYYY"

#define TEMP_NEWSPAPER_URL @"http://www.thedaonline.com/polopoly_fs/1.1678168!/20101012.pdf"

@implementation NewspaperSelectionViewController

-(void)viewDidLoad{
	dateChangeIsProgramatic = NO;
	PDFToolbar.tintColor = [UIColor WVUBlueColor];
	if([[Reachability sharedReachability] internetConnectionStatus] != NotReachable){
		dateToDownload = [[NSDate date] retain];
		loadingView = [[JCLoadingView alloc] initWithTitle:NEWSPAPER_FINDING_TEXT message:[dateToDownload stringWithFormat:NEWSPAPER_DATE_FORMAT]];
		[loadingView showLoadingViewInView:self.view];
		[self downloadPaper];
	}
}




-(IBAction)datePickerDateChanged:(UIDatePicker *)sender{
	[currentLocalURL release];
	currentLocalURL = nil;
	displayPaperButton.enabled = NO;
	
	if ((!dateChangeIsProgramatic)&&(!manualMode)){
		manualMode = YES;
		[loadingView dismissLoadingViewAndReappearWithTitle:@"Manual Selection" andMessage:@"Select a date below."];
		[loadingView performSelector:@selector(dismissLoadingView) withObject:nil afterDelay:5];
	}
	
	
	if (manualMode) {
		dateToDownload = sender.date;
		[self downloadPaper];
	}
 
}

																										
		

-(NSDate *)oneDayAgoFrom:(NSDate *)date{
    //using DateComponents to get the next calendar day to avoid DST bug
    NSDateComponents *oneDay = [[NSDateComponents alloc] init];
    [oneDay setDay:-1];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *oneDayFromDate = [gregorian dateByAddingComponents:oneDay toDate:date options:0];
    [oneDay release];
    [gregorian release];
    return oneDayFromDate;
}


-(NSString *)directoryForPapers{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES); 
	NSString *aPath = [paths objectAtIndex:0];
	aPath = [aPath stringByAppendingPathComponent:@"Newspaper"];
	aPath = [aPath stringByExpandingTildeInPath];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if([fileManager contentsOfDirectoryAtPath:aPath error:NULL] == nil){
		//the directory doesn't exist
		[fileManager createDirectoryAtPath:aPath withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	return aPath;
}

- (void)dealloc {
	[downloadThread cancel];
	[downloadThread release];
	[dateToDownload release];
	[interactionController release];
    [super dealloc];
}


-(IBAction)displayNewspaper{
	if(currentLocalURL){
		[interactionController release];
		interactionController = [UIDocumentInteractionController interactionControllerWithURL:currentLocalURL];
		[interactionController retain];
		interactionController.delegate = self;
		interactionController.name = [NSString stringWithFormat:@"The DA: %@", [dateToDownload stringWithFormat:NEWSPAPER_DATE_FORMAT]];
		[interactionController presentPreviewAnimated:YES];
		[loadingView dismissLoadingView];
	}
}

-(void)downloadOfNewspaperFailed{
	if (!manualMode) {
		if ([dateToDownload daysAgo] < MAX_NUMBER_OF_DAYS_AGO_TO_SEARCH ) {
			dateToDownload = [self oneDayAgoFrom:dateToDownload];
			[self downloadPaper];
			[loadingView dismissLoadingViewAndReappearWithTitle:NEWSPAPER_FINDING_TEXT andMessage:[dateToDownload stringWithFormat:NEWSPAPER_DATE_FORMAT]];
			[datePicker setDate:dateToDownload animated:YES];
			//update date picker
		}
		else {
			[loadingView dismissLoadingViewAndReappearWithTitle:@"No edition found" andMessage:nil];
			[loadingView performSelector:@selector(dismissLoadingView) withObject:nil afterDelay:5];
			dateToDownload = nil;
		}
	}
}

-(void)downloadOfNewspaperSucceeded{
	if (!manualMode) {
		[self displayNewspaper];
	}
	else {
		[loadingView dismissLoadingViewAndReappearWithTitle:@"Download Succeeded" andMessage:nil];
		displayPaperButton.enabled = YES;
	}

}

-(NSString *)remoteURLforDate:(NSDate *)date{
	NSString *baseURL = @"http://www.wvu.edu/~wvuda/";
	NSString *editionDate = [[date description] substringToIndex:10]; 
	NSString *pageURL = [NSString stringWithFormat:@"%@%@/Page%@1.pdf",baseURL,editionDate,@"%20"];
	NSLog(@"%@", pageURL);
	return pageURL;
}


-(void)downloadPaper{
	if (downloadThread) {
		[downloadThread cancel];
		[downloadThread release];
	}
	downloadThread = [[NSThread alloc] initWithTarget:self selector:@selector(attemptToDownloadNewspaperForDate:) object:dateToDownload];
	[downloadThread start];
}

-(void)attemptToDownloadNewspaperForDate:(NSDate *)date{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSURL *remoteURL = [NSURL URLWithString:[self remoteURLforDate:date]];
	NSString *aPath = [self directoryForPapers];
	NSString *newspaperName = [NSString stringWithFormat:@"%@.pdf",[date calendarDateString]];
	aPath = [aPath stringByAppendingPathComponent:newspaperName];
	//NSURL *localURL = [[NSURL URLWithString:aPath] retain];
	NSURL *localURL = [[NSURL fileURLWithPath:aPath isDirectory:NO] retain];
	NSData *newspaperData = [NSData dataWithContentsOfURL:remoteURL];
	[NSThread sleepForTimeInterval:1];
	if (newspaperData) {
		[newspaperData writeToURL:localURL atomically:YES];
		currentLocalURL = [localURL retain];
		[self performSelectorOnMainThread:@selector(downloadOfNewspaperSucceeded) withObject:localURL waitUntilDone:NO];
	}
	else {
		[self performSelectorOnMainThread:@selector(downloadOfNewspaperFailed) withObject:nil waitUntilDone:NO];
	}
	
	[localURL release];
	downloadThread = nil;
	[pool release];
}


- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
	return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller{
	return datePicker;
}

- (void)documentInteractionControllerWillBeginPreview:(UIDocumentInteractionController *)controller{
	//
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller{
	//
}


-(IBAction)goToTodaysDate{
	[datePicker setDate:[NSDate date] animated:YES];
}


@end
