/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalView.h" // for the KalViewDelegate protocol

@class KalLogic;

@protocol KalDataSource;

/*
 *    KalViewController
 *    ------------------------
*
 *  KalViewController automatically creates both the calendar view
 *  and the events table view for you. The only thing you need to provide
 *  is a KalDataSource so that the calendar system knows which days to
 *  mark with a dot and which events to list under the calendar when a certain
 *  date is selected (just like in Apple's calendar app).
 *
 */
@interface KalViewController : UIViewController <KalViewDelegate>
{
  KalLogic *logic;
  UITableView *tableView;
  id <KalDataSource> dataSource;
  id <UITableViewDelegate> tableViewDelegate;
}

@property (nonatomic, assign) id <UITableViewDelegate> tableViewDelegate;

- (id)initWithDataSource:(id<KalDataSource>)source; // designated initializer

- (void)showAndSelectToday;

-(void)refresh;

@end
