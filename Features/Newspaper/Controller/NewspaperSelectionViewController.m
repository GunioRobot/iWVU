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
#import "NSDate+StringCalendarDate.h"
//#import "TwitterBubbleViewController.h"

#define MAX_NUMBER_OF_DAYS_AGO_TO_SEARCH 7.0
#define NEWSPAPER_FINDING_TEXT @"Finding the most recent edition"
#define NEWSPAPER_DOWNLOADING_TEXT @"Downloading the DA"
#define NEWSPAPER_DOWNLOAD_FAILED_TEXT @"Edition not found"
#define NEWSPAPER_INTERNET_CONNECTION_ERROR_TEXT @"Internet required for download"
#define NEWSPAPER_DATE_FORMAT @"MMM d, YYYY"

@interface NewspaperSelectionViewController()
-(void)findMostRecentEdition;
@end


@implementation NewspaperSelectionViewController

-(void)viewDidLoad{
	
	UIImage *flyingWVTwitter = [UIImage imageNamed:@"DANameLogo.png"];
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:flyingWVTwitter];
	self.navigationItem.title = @"The DA";
	
	[datePicker setDate:[NSDate date]];
	[datePicker setMaximumDate:[NSDate date]];
	PDFToolbar.tintColor = [UIColor applicationPrimaryColor];
	[self findMostRecentEdition];
}


-(void)findMostRecentEdition{
	if([[Reachability sharedReachability] internetConnectionStatus] != NotReachable){
		manualMode = NO;
		numberOfDatesSearched = 1;
		[self downloadPaper];
		downloadIndicator = [[JCDismissableDownloadIndicator alloc] initWithProgressTitle:NEWSPAPER_FINDING_TEXT];
		downloadIndicator.delegate = self;
		[downloadIndicator show];
		downloadIndicator.progressBar.progress = numberOfDatesSearched/MAX_NUMBER_OF_DAYS_AGO_TO_SEARCH;
	}
	else {
		downloadIndicator = [[JCDismissableDownloadIndicator alloc] initWithProgressTitleButNoProgressBar:NEWSPAPER_INTERNET_CONNECTION_ERROR_TEXT];
		downloadIndicator.delegate = self;
		[downloadIndicator show];
	}

	
}


-(IBAction)datePickerDateChanged:(UIDatePicker *)sender{
	currentLocalURL = nil;
 
}

																										
		

-(NSDate *)oneDayAgoFrom:(NSDate *)date{
    //using DateComponents to get the next calendar day to avoid DST bug
    NSDateComponents *oneDay = [[NSDateComponents alloc] init];
    [oneDay setDay:-1];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *oneDayFromDate = [gregorian dateByAddingComponents:oneDay toDate:date options:0];
    return oneDayFromDate;
}


-(NSString *)directoryForPapers{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES); 
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
	[downloadIndicator hide];
}


-(IBAction)displayNewspaper{
	if(currentLocalURL){
		interactionController = [UIDocumentInteractionController interactionControllerWithURL:currentLocalURL];
		interactionController.delegate = self;
		interactionController.name = [NSString stringWithFormat:@"The DA: %@", [datePicker.date stringWithFormat:NEWSPAPER_DATE_FORMAT]];
		[interactionController presentPreviewAnimated:YES];
		[downloadIndicator hide];
		downloadIndicator = nil;
		manualMode = YES;
	}
}

-(void)downloadOfNewspaperFailed{
	if (!manualMode) {
		if ([datePicker.date daysAgo] < MAX_NUMBER_OF_DAYS_AGO_TO_SEARCH ) {
			[datePicker setDate:[self oneDayAgoFrom:datePicker.date] animated:YES];
			[self downloadPaper];
			
			numberOfDatesSearched++;
			downloadIndicator.progressBar.progress = numberOfDatesSearched/MAX_NUMBER_OF_DAYS_AGO_TO_SEARCH;
			
			
		}
		else {
			[downloadIndicator hide];
			downloadIndicator = [[JCDismissableDownloadIndicator alloc] initWithProgressTitleButNoProgressBar:NEWSPAPER_DOWNLOAD_FAILED_TEXT];
			downloadIndicator.delegate = self;
			[downloadIndicator show];
			manualMode = YES;
		}
	}
	else {
		[downloadIndicator hide];
		downloadIndicator = [[JCDismissableDownloadIndicator alloc] initWithProgressTitleButNoProgressBar:NEWSPAPER_DOWNLOAD_FAILED_TEXT];
		downloadIndicator.delegate = self;
		[downloadIndicator show];
	}

}

-(void)downloadOfNewspaperSucceeded{
	[self displayNewspaper];
}

-(NSString *)remoteURLforDate:(NSDate *)date{
	NSString *baseURL = @"http://www.wvu.edu/~wvuda/";
	NSString *editionDate = [[date description] substringToIndex:10]; 
	NSString *pageURL = [NSString stringWithFormat:@"%@%@/Page%@1.pdf",baseURL,editionDate,@"%20"];
	NSLog(@"%@", pageURL);
	return pageURL;
}


-(IBAction)downloadPaper{
	
	// Create the request. 
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:[self remoteURLforDate:datePicker.date]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	// create the connection with the request 
	// and start loading the data 
	[currentConnection cancel];
	currentConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self]; 
	if (currentConnection) {
		// Create the NSMutableData to hold the received data. 
		// receivedData is an instance variable declared elsewhere. 
		receivedData = [NSMutableData data];
	} else { 
		// Inform the user that the connection failed.
		[self downloadOfNewspaperFailed];
	}
	
}




- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
	
	
	if ([[response MIMEType] isEqualToString:@"application/pdf"]) {
		[downloadIndicator hide];
		downloadIndicator = [[JCDismissableDownloadIndicator alloc] initWithProgressTitle:NEWSPAPER_DOWNLOADING_TEXT];
		downloadIndicator.delegate = self;
		[downloadIndicator show];
		
		
		
		if ([response expectedContentLength] != NSURLResponseUnknownLength) {
			downloadFullSize = [response expectedContentLength];
			downloadCurrentSize = 0;
		}
	}
	else {
		[currentConnection cancel];
		currentConnection = nil;
		[self downloadOfNewspaperFailed];
	}

	
	
	
}



- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
	
	downloadCurrentSize += [data length];
	downloadIndicator.progressBar.progress = ((float)(downloadCurrentSize))/((float)(downloadFullSize));

}



- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
	currentConnection = nil;
    // receivedData is declared as a method instance elsewhere
	receivedData = nil;
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [error userInfo]);
	
	[self downloadOfNewspaperFailed];
}



- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
    // release the connection, and the data object
	currentConnection = nil;
	
	NSString *aPath = [self directoryForPapers];
	NSString *newspaperName = [NSString stringWithFormat:@"%@.pdf",[datePicker.date calendarDateString]];
	aPath = [aPath stringByAppendingPathComponent:newspaperName];
	NSURL *localURL = [NSURL fileURLWithPath:aPath isDirectory:NO];
	[receivedData writeToURL:localURL atomically:YES];
	currentLocalURL = localURL;
	receivedData = nil;
	[self downloadOfNewspaperSucceeded];
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
	NSError *err = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[self directoryForPapers] error:&err];
    NSLog(@"%@",err);
}


-(IBAction)goToTodaysDate{
	[datePicker setDate:[NSDate date] animated:YES];
}

-(void)downloadIndicatorDismissed:(JCDismissableDownloadIndicator *)indicator{
	[currentConnection cancel];
	downloadIndicator = nil;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
		return 3;
	}
	return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	[AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ((cell == nil)||(indexPath.section == 3)) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.textAlignment = UITextAlignmentLeft;
	
	if(indexPath.section == 0){
		cell.textLabel.text = @"theDAonline.com";
	}
	else if(indexPath.section == 1){
		cell.textLabel.text = @"@DailyAthenaeum";
	}
	else if(indexPath.section == 2){
		if (indexPath.row == 0) {
			cell.textLabel.text = @"News";
		}
		else if(indexPath.row == 1){
			cell.textLabel.text = @"Opinion";
		}
		else if(indexPath.row == 2){
			cell.textLabel.text =@"Sports";
		}
	}

	
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 0){
		return @"Mobile Website";
	}
	else if(section == 1){
		return @"Twitter";
	}
	else if(section == 2){
		return @"Sections";
	}
	return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if(indexPath.section == 0){
		OPENURL(@"http://www.thedaonline.com/");
	}
	else if(indexPath.section == 1){
        /*
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		NSString *userName = [cell.textLabel.text substringFromIndex:1];
		TwitterBubbleViewController *viewController = [[TwitterBubbleViewController alloc] initWithUserName:userName];
		viewController.navigationItem.title = cell.textLabel.text;
		[self.navigationController pushViewController:viewController animated:YES];
		[viewController release];
         */
	}
	else if(indexPath.section == 2){
		if (indexPath.row == 0) {
			OPENURL(@"http://www.thedaonline.com/news");
		}
		else if(indexPath.row == 1){
			OPENURL(@"http://www.thedaonline.com/opinion");
		}
		else if(indexPath.row == 2){
			OPENURL(@"http://www.thedaonline.com/sports");
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	//these are the default's, but I'm going to explicitly define them, just to be safe
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		return (UIInterfaceOrientationPortrait == interfaceOrientation);
	}
	return YES;
}



@end
