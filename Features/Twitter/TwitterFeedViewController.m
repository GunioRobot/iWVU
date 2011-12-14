//
//  TwitterFeedViewController.m
//  USPTO
//
//  Created by Jared Crawford on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TwitterFeedViewController.h"
#import <Twitter/Twitter.h>
#import "JMImageCache.h"
#import "TwitterTableViewCell.h"
#import "UIColor+ApplicationColors.h"

@interface TwitterFeedViewController()<JMImageCacheDelegate>
-(void)refreshTableViewWithNewTweets:(NSArray *)newTweets;
-(void)downloadOfTweetsFailed;
-(void)downloadTweets;
@end


@implementation TwitterFeedViewController

@synthesize account;
@synthesize list;

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        tweets = [NSArray array];
        page = 0;
        self.account = @"USPTO";
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor applicationBackgroundColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    if ([TWTweetComposeViewController canSendTweet]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(reply)];
    }
    [self downloadTweets];
}


-(NSString *)numberOfTweetPerPage{
    return @"50";
}

-(NSString *)currentPage{
    page++;
    return [NSString stringWithFormat:@"%d", page];
}

-(void)resetPage{
    page = 0;
}

-(NSString *)shouldIncludeRetweets{
    return @"true";
}

-(void)downloadTweets{
    if (self.account) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSURL *timeLineURL= [NSURL URLWithString:@"http://api.twitter.com/1/statuses/user_timeline.json"];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [self numberOfTweetPerPage],@"count",
                                    [self currentPage], @"page",
                                    [self shouldIncludeRetweets],@"include_rts",
                                    self.account, @"screen_name",
                                    nil];
        TWRequest *myTimeLine = [[TWRequest alloc] initWithURL:timeLineURL parameters:parameters requestMethod:TWRequestMethodGET];
        [myTimeLine performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if ([urlResponse statusCode] == 200) {
                id results = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                
                dispatch_async(dispatch_get_main_queue(), ^{ 
                    [self refreshTableViewWithNewTweets:results];
                });
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{ 
                    [self downloadOfTweetsFailed];
                });
            }
            
        }];
    }
}


-(void)refreshTableViewWithNewTweets:(NSArray *)newTweets{
    if (newTweets) {
        tweets = [tweets arrayByAddingObjectsFromArray:newTweets];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
    }
    else{
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)downloadOfTweetsFailed{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)reply{
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
    tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result) {
        [self dismissModalViewControllerAnimated:YES]; 
    };
    if (account) {
        [tweetSheet setInitialText:[NSString stringWithFormat:@"@%@ ", account]];
    }
    [self presentModalViewController:tweetSheet animated:YES];
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [tweets count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
    if(indexPath.section == 1){
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"bottom"];
        cell.textLabel.text = @"Load more…";
        return cell;
    }
    
    TwitterTableViewCell *cell;
    if (indexPath.section == 0) {
        if(indexPath.row%2 != 9){
            NSString *reuse = @"left";
            cell = [tableView dequeueReusableCellWithIdentifier:reuse];
            if (!cell) {
                cell = [[TwitterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
            }
            cell.isRightAligned = NO;
        }
        else{
            NSString *reuse = @"right";
            cell = [tableView dequeueReusableCellWithIdentifier:reuse];
            if (!cell) {
                cell = [[TwitterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
            }
            cell.isRightAligned = YES;
        }
        NSDictionary *tweet = [tweets objectAtIndex:indexPath.row];
        [cell configureWithTweet:tweet];
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        NSDictionary *tweet = [tweets objectAtIndex:indexPath.row];
        NSString *text = [tweet objectForKey:@"text"];
        return [TwitterTableViewCell heightForCellWithText:text inViewWithWidth:tableView.frame.size.width];
    }
    return 95.0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *tweet = [tweets objectAtIndex:indexPath.row];
    NSString *text = [tweet objectForKey:@"text"];
    NSMutableArray *urls = [NSMutableArray array];
    for (NSString *word in [text componentsSeparatedByString:@" "]) {
        if ([word hasPrefix:@"http://"]) {
            [urls addObject:word];
        }
    }
    
    if ([urls count] > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Temporary" message:[urls objectAtIndex:0] delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil];
        [alert show];
    }
}

-(BOOL)iPadOptimized{
    return NO;
}

@end
