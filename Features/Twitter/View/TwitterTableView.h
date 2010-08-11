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


typedef enum {
	refreshStatuses,
	downloadMoreStatuses,
	noMoreLoading
} selectedLoadType;


@interface TwitterTableView : PullRefreshTableView <MGTwitterEngineDelegate, UITableViewDelegate, UITableViewDataSource> {
	
	UITableView *theTableView;
	
	NSArray *statusMessages; //NSArray of NSDictionaries
	NSArray *bubbles;
	
	NSString *twitterUserName;
	UIImage *userImage;
	
	MGTwitterEngine *twitterEngine;
	
	selectedLoadType aLoadType;
	
	int currentPage;
	
	BOOL haveRequestedUserImage;
	NSThread *downloadImageThread;
    
	
}

@property (nonatomic, retain) NSString *twitterUserName;
@property (nonatomic, retain) UIImage *userImage; 

-(id)initWithFrame:(CGRect)frame;
-(void)reloadTableViewAnimated;


@end
