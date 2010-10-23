//
//  NewspaperSelectionViewController.h
//  iWVU
//
//  Created by Jared Crawford on 10/12/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCLoadingView.h"

@interface NewspaperSelectionViewController : UIViewController <UIDocumentInteractionControllerDelegate>{
	NSDate *dateToDownload;
	IBOutlet UIDatePicker *datePicker;
	IBOutlet UIBarButtonItem *displayPaperButton;
	JCLoadingView *loadingView;
	BOOL dateChangeIsProgramatic;
	BOOL manualMode;
	NSThread *downloadThread;
	UIDocumentInteractionController *interactionController;
	NSURL *currentLocalURL;
	IBOutlet UIToolbar *PDFToolbar;
}

-(IBAction)goToTodaysDate;
-(IBAction)datePickerDateChanged:(UIDatePicker *)sender;
-(IBAction)displayNewspaper;
-(void)downloadPaper;

@end
