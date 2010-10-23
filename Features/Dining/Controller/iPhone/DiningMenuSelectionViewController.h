//
//  DiningMenuSelectionViewController.h
//  iWVU
//
//  Created by Jared Crawford on 9/5/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>

@interface DiningMenuSelectionViewController : UITableViewController{
	
	NSString *diningLocationName;
	NSString *diningLocationID;
	UIActivityIndicatorView *spinner;
	NSArray *currentDiningData;
	NSArray *currentDiningMeals;
	
	//UITableView *tableView;
	
	UIDatePicker *theDatePicker;
	
	NSThread *diningDataDownloadThread;
	
}


-(id)initWithDiningLocation:(NSString *)diningLocationID;
-(IBAction)datePickerValueChanged:(UIDatePicker *)datePicker;

@end
