//
//  TwitterTableView.h
//  iWVU
//
//  Created by Jared Crawford on 6/26/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGTwitterEngine.h"


typedef enum {
	refreshStatuses,
	downloadMoreStatuses,
	noMoreLoading
} selectedLoadType;


@interface TwitterTableView : UITableView <MGTwitterEngineDelegate, UITableViewDelegate, UITableViewDataSource> {
	
	UITableView *theTableView;
	
	NSArray *statusMessages; //NSArray of NSDictionaries
	NSArray *bubbles;
	
	NSString *twitterUserName;
	UIImage *userImage;
	
	MGTwitterEngine *twitterEngine;
	
	selectedLoadType aLoadType;
	
	int currentPage;
	
}

@property (nonatomic, retain) NSString *twitterUserName;

-(id)initWithFrame:(CGRect)frame;

@end
