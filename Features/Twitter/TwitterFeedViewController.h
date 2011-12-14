//
//  TwitterFeedViewController.h
//  USPTO
//
//  Created by Jared Crawford on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterFeedViewController : UITableViewController{
    NSArray *tweets;
    NSInteger page;
}

@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *list;

@end
