//
//  TwitterUserListViewController.h
//  iWVU
//
//  Created by Jared Crawford on 10/5/09.
//  Copyright 2009 Jared Crawford. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TwitterUserListViewController : UITableViewController {

	NSDictionary *userData;
	NSArray *userNames;
	
}


@property (nonatomic, retain) NSDictionary *userData;
@property (nonatomic, retain) NSArray *userNames;
@end
