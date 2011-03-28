//
//  DiningMenuSelectionViewController.h
//  iWVU
//
//  Created by Jared Crawford on 9/5/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>

@interface DiningMenuSelectionViewController : UIViewController{
	
	NSString *diningLocationName;
	NSString *diningLocationID;
	UIActivityIndicatorView *spinner;
	NSArray *currentDiningData;
	NSArray *currentDiningMeals;
	NSLock *diningDataLock;
	TKEmptyView *emptyView;
	
	IBOutlet UITableView *tableView;
	
	IBOutlet UIDatePicker *theDatePicker;
	
	NSThread *diningDataDownloadThread;
	
}


-(id)initWithDiningLocation:(NSString *)aDiningLocationID andName:(NSString *)name;
-(IBAction)datePickerValueChanged:(UIDatePicker *)datePicker;
-(void)downloadNewMenuData;
-(void)reloadTableViewAnimated:(BOOL)animated;

@end
