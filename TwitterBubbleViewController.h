//
//  TwitterBubbleViewController.h
//  iWVU
//
//  Created by Jared Crawford on 10/4/09.
//  Copyright Jared Crawford 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGTwitterEngine.h"


typedef enum {
	refreshStatuses,
	downloadMoreStatuses
} selectedLoadType;

@interface TwitterBubbleViewController : UITableViewController <MGTwitterEngineDelegate, UITableViewDelegate, UITableViewDataSource>{

	
	NSArray *statusMessages; //NSArray of NSDictionaries
	NSArray *bubbles;
	
	NSString *twitterUserName;
	
	MGTwitterEngine *twitterEngine;
	
	selectedLoadType aLoadType;
	
	int currentPage;
	
}

@property (nonatomic, retain) NSString *twitterUserName;

-(id)initWithUserName:(NSString *)aUserName;


@end

