//
//  DiningMenuSelectionViewController.m
//  iWVU
//
//  Created by Jared Crawford on 9/5/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "DiningMenuSelectionViewController.h"
#import <TapkuLibrary/TapkuLibrary.h>


#define DINING_BASE_URL @"http://protected.wvu.edu/diningmenu/json.php?id=%@&day=%@"
#define MENU_DAYS_AVAILABLE 5


@implementation DiningMenuSelectionViewController


-(id)initWithDiningLocation:(NSString *)aDiningLocationID andName:(NSString *)name{
	if (self = [self initWithNibName:@"DiningMenuSelectionViewController" bundle:nil]) {
		diningDataLock = [[NSLock alloc] init];
		[diningDataLock lock];
		diningLocationID = aDiningLocationID;
		diningLocationName = name;
		currentDiningData = [NSArray array];
		currentDiningMeals = [NSArray array];
		[diningDataLock unlock];
	}
	return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
	//tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin);
	//tableView.delegate = self;
	//tableView.dataSource = self;
	//[self.view addSubview:tableView];
	//self.header.title.text = diningLocationName;
	//self.header.subtitle.text = @"Menu";
	//self.header.indicator.text = [[NSDate date] stringWithFormat:@"M/d/YYYY"];
	theDatePicker.minimumDate = [NSDate date];
	theDatePicker.maximumDate = [NSDate dateWithTimeIntervalSinceNow:(60*60*24*MENU_DAYS_AVAILABLE)];
	theDatePicker.date = [NSDate date];
	theDatePicker.frame = CGRectMake(0, self.view.frame.size.height, theDatePicker.frame.size.width, theDatePicker.frame.size.height);
	//tableView.frame = self.view.frame;
	[self.view bringSubviewToFront:theDatePicker];
	tableView.allowsSelection = NO;
	self.navigationItem.title = @"Menu";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Calendar.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(dateSelectionButtonPressed)];
	[self downloadNewMenuData];
	
}


-(IBAction)datePickerValueChanged:(UIDatePicker *)aDatePicker{
	[self  downloadNewMenuData];
}


-(void)downloadNewMenuData{
	[diningDataLock lock];
	currentDiningData = nil;
	if (diningDataDownloadThread) {
		[diningDataDownloadThread cancel];
		diningDataDownloadThread = nil;
	}
	[diningDataLock unlock];
	
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"M/d/YYYY"];
	NSString *date = [inputFormatter stringFromDate:theDatePicker.date];
	
	NSString *url = [NSString stringWithFormat:DINING_BASE_URL, diningLocationID, date];
	diningDataDownloadThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadNewMenuDataThreaded:) object:url];
	[diningDataDownloadThread start];
}

-(void)downloadNewMenuDataThreaded:(NSString *)url{
	@autoreleasepool {
	
		NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
		NSError *err;
    NSArray *menuData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
		//NSLog(@"%@", menuData);
		if (![[NSThread currentThread] isCancelled]) {
			if (menuData) {
				[self performSelectorOnMainThread:@selector(haveNewDiningData:) withObject:menuData waitUntilDone:NO];
			}
			else if(err){
				NSLog(@"%@",[err description]);
				[self performSelectorOnMainThread:@selector(errorDownloadingDiningData) withObject:nil waitUntilDone:NO];
			}
		}
		diningDataDownloadThread = nil;
	}
}



-(NSString *)cleanUpString:(NSString*)clutteredString{
	NSString *cleanedStr = [clutteredString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
	cleanedStr = [cleanedStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	return cleanedStr;
}


-(void)displayEmptyView{
	if (!emptyView) {
		emptyView = [[TKEmptyView alloc] initWithFrame:self.view.frame mask:[UIImage imageNamed:@"DiningEmptyView.png"] title:@"Menu Unavailable" subtitle:@"No menu data is available for the selected date."];
		[self.view addSubview:emptyView];
		[self.view bringSubviewToFront:theDatePicker];
	}
}


-(void)haveNewDiningData:(NSArray *)downloadedDiningData{
	[diningDataLock lock];
	currentDiningData = nil;
	[diningDataLock unlock];
	
	NSMutableArray *sortedNewData = [[NSMutableArray alloc] init];
	NSMutableArray *sortedNewSections = [[NSMutableArray alloc] init];
	NSString *previousMealName = @"";
	NSString *itemName;
	NSString *mealName;
	for (NSDictionary *dict in downloadedDiningData){
		//make sure its not a blank string, we can discard those entries
		itemName = [self cleanUpString:[dict objectForKey:@"item"]];
		mealName = [self cleanUpString:[dict objectForKey:@"meal"]];
		if (![@"" isEqualToString:itemName]) {
			//if this item is of the same type as the previous one (e.g. breakfast)
			//then we want to add that to the same array
			if ([previousMealName isEqualToString:mealName]) {
				NSArray *oldArray = [sortedNewData lastObject];
				[sortedNewData removeLastObject];
				NSArray *newArray = [oldArray arrayByAddingObject:itemName];
				[sortedNewData addObject:newArray];
			}
			else {
				NSArray *newArray = [NSArray arrayWithObject:itemName];
				[sortedNewData addObject:newArray];
				[sortedNewSections addObject:mealName];
			}

		}
		previousMealName = mealName;
		
	}
	
	[diningDataLock lock];
	currentDiningData = [NSArray arrayWithArray:sortedNewData];
	currentDiningMeals = [NSArray arrayWithArray:sortedNewSections];
	[diningDataLock unlock];
	if ([currentDiningData count] == 0) {
		[self displayEmptyView];
	}
	else {
		[self reloadTableViewAnimated:YES];
	}

	
}


-(void)dateSelectionButtonPressed{

	static BOOL datePickerIsHidden = YES;
	
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:.7];
		
		if(datePickerIsHidden){
			theDatePicker.frame=  CGRectMake(0,self.view.frame.size.height - theDatePicker.frame.size.height, theDatePicker.frame.size.width, theDatePicker.frame.size.height);
			tableView.contentInset = UIEdgeInsetsMake(0, 0, theDatePicker.frame.size.height, 0);
			tableView.scrollIndicatorInsets = tableView.contentInset;
			
		}
		else{
			theDatePicker.frame = CGRectMake(0, self.view.frame.size.height, theDatePicker.frame.size.width, theDatePicker.frame.size.height);
			tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
			tableView.scrollIndicatorInsets = tableView.contentInset;
		}
		
		[UIView commitAnimations];
	
	if (datePickerIsHidden) {
		datePickerIsHidden = NO;
	}
	else {
		datePickerIsHidden = YES;
	}


}


-(void)errorDownloadingDiningData{
	
}




-(void)reloadTableViewAnimated:(BOOL)animated{
	[diningDataLock lock];
	
	if (emptyView) {
		[emptyView removeFromSuperview];
		emptyView = nil;
	}
	
	if (animated) {
		[tableView beginUpdates];
		NSIndexSet *sectionsToReload = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tableView numberOfSections])];
		[tableView reloadSections:sectionsToReload withRowAnimation:UITableViewRowAnimationFade];
		if ([currentDiningData count] > [tableView numberOfSections]) {
			NSRange sectionsToAdd = NSMakeRange([tableView numberOfSections], [currentDiningData count] - [tableView numberOfSections]);
			[tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:sectionsToAdd] withRowAnimation:UITableViewRowAnimationFade];
		}
		else if([currentDiningData count] < [tableView numberOfSections]){
			NSRange sectionsToRemove = NSMakeRange([currentDiningData count], [tableView numberOfSections] - [currentDiningData count]);
			[tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:sectionsToRemove] withRowAnimation:UITableViewRowAnimationFade];
		}
		[tableView reloadSectionIndexTitles];
		[tableView endUpdates];
	}
	else {
		[tableView reloadData];
	}
	[diningDataLock unlock];
}

		 
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[currentDiningData objectAtIndex:section] count];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [currentDiningData count];
}


- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	[AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
}





- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
	
	
	cell.textLabel.text = [[currentDiningData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return [currentDiningMeals objectAtIndex:section];
}


@end
