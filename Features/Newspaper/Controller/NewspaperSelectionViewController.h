//
//  NewspaperSelectionViewController.h
//  iWVU
//
//  Created by Jared Crawford on 10/12/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCLoadingView.h"
#import "JCDismissableDownloadIndicator.h"

@interface NewspaperSelectionViewController : UIViewController <UIDocumentInteractionControllerDelegate, JCDismissableDownloadIndicatorDelegate, UITableViewDelegate, UITableViewDataSource>{
	IBOutlet UIDatePicker *datePicker;
	IBOutlet UIToolbar *PDFToolbar;
	
	int numberOfDatesSearched;
	
	BOOL manualMode;
	UIDocumentInteractionController *interactionController;
	NSURL *currentLocalURL;
	
	NSMutableData *receivedData;
	NSURLConnection *currentConnection;
	long long downloadFullSize;
	long long downloadCurrentSize;
	JCDismissableDownloadIndicator *downloadIndicator;
}

-(IBAction)goToTodaysDate;
-(IBAction)datePickerDateChanged:(UIDatePicker *)sender;
-(IBAction)displayNewspaper;
-(IBAction)downloadPaper;

@end
