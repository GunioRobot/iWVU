//
//  TwitterTableView.h
//  iWVU
//
//  Created by Jared Crawford on 6/26/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGTwitterEngine.h"
#import "PullRefreshTableView.h"
#import "TwitterUserIconDB.h"


typedef enum {
	refreshStatuses,
	downloadMoreStatuses,
	noMoreLoading
} selectedLoadType;


@interface TwitterTableView : PullRefreshTableView <MGTwitterEngineDelegate, UITableViewDelegate, UITableViewDataSource, TwitterUserIconDBDelegate, UIActionSheetDelegate> {
	
	UITableView *theTableView;
	
	NSArray *statusMessages; //NSArray of NSDictionaries
	NSArray *bubbles;
	
	NSString *twitterUserName;
    
	
	MGTwitterEngine *twitterEngine;
	
	selectedLoadType aLoadType;
	
	int currentPage;
	
	TwitterUserIconDB *iconDB;
	
}

@property (nonatomic, retain) NSString *twitterUserName;

-(id)initWithFrame:(CGRect)frame;
-(void)reloadTableViewAnimated;


@end
