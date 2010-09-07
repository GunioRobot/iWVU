//
//  DiningMenuSelectionViewController.h
//  iWVU
//
//  Created by Jared Crawford on 9/5/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DiningMenuSelectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{

	NSString *diningLocation;
	UIActivityIndicatorView *spinner;
	NSArray *currentDiningData;
	NSArray *currentDiningMeals;
	
	IBOutlet UIDatePicker *theDatePicker;
	IBOutlet UITableView *theTableView;
	
	NSThread *diningDataDownloadThread;
	
}


-(id)initWithDiningLocation:(NSString *)diningLocationID;
-(IBAction)datePickerValueChanged:(UIDatePicker *)datePicker;

@end
