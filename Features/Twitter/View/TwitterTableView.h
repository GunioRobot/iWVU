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
	NSString *twitterListName;
	
	bool anErrorHasOccured;
    
	NSString *textOfSelectedTweet;
	
	MGTwitterEngine *twitterEngine;
	
	selectedLoadType aLoadType;
	
	int currentPage;
	
	TwitterUserIconDB *iconDB;
	
}

-(id)initWithFrame:(CGRect)frame;
-(void)reloadTableViewAnimated;
-(void)setTwitterUserName:(NSString *)userName;
-(void)setTwitterList:(NSString *)listName onAccount:(NSString *)accountName;
-(NSString *)getUserName;

@end
