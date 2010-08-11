//
//  TwitterTableView.m
//  iWVU
//
//  Created by Jared Crawford on 6/26/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "TwitterTableView.h"

#import "MGTwitterEngine.h"
#import <TapkuLibrary/TapkuLibrary.h>
#import "TwitterTableViewCell.h"
#import "UIImage+RoundedCorner.h"


#define NumberOfMessageToDowload 0


typedef enum{
	ChatBubbleTypeBlue,
	ChatBubbleTypeYellow
} ChatBubbleType;


@implementation TwitterTableView

@synthesize twitterUserName;
@synthesize userImage;

-(id)initWithFrame:(CGRect)frame{
	
	if (self = [super initWithFrame:frame style:UITableViewStylePlain]) {
		self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
		self.delegate = self;
		self.dataSource = self;
		
		aLoadType = refreshStatuses;
		currentPage = 1;
		self.separatorStyle = UITableViewCellSeparatorStyleNone;
		//219, 226, 237
		//self.backgroundColor =[UIColor colorWithRed:(219./255) green:(226./255) blue:(237./255) alpha:1];
		self.backgroundColor = [UIColor viewBackgroundColor];
		
		twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
		
		haveRequestedUserImage = NO;
		
		return self;
	}
	return nil;
}




-(void)addFooterToTableView{
	UIButton *showMoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[showMoreButton setTitle:@"Load More" forState:UIControlStateNormal];
	showMoreButton.frame = CGRectMake(0, 0, 70, 40);
	showMoreButton.contentMode = UIViewContentModeTop;
	[showMoreButton addTarget:self action:@selector(downloadMoreFromTwitter) forControlEvents:UIControlEventTouchUpInside];
	self.tableFooterView = showMoreButton;
}

-(void)refresh{
	aLoadType = refreshStatuses;
	currentPage = 1;
	[twitterEngine getUserTimelineFor:twitterUserName sinceID:0 startingAtPage:currentPage count:NumberOfMessageToDowload];
}

-(void)setTwitterUserName:(NSString *)userName{
	[twitterUserName release];
	if (userName) {
		twitterUserName = [userName retain];
		[self refresh];
	}
	else {
		twitterUserName = nil;
	}
}

-(void)downloadMoreFromTwitter{
	aLoadType = downloadMoreStatuses;
	currentPage++;
	if ([statusMessages count] > 0) {
		[twitterEngine getUserTimelineFor:twitterUserName sinceID:0 startingAtPage:currentPage count:NumberOfMessageToDowload];
	}
}


- (void)requestSucceeded:(NSString *)requestIdentifier{
	[self addFooterToTableView];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error{
	NSString *subtitle = @"Try again later.";
	if([error code] == -1009){
		subtitle = @"An internet connection is required";
	}
	TKEmptyView *emptyView = [[TKEmptyView alloc] initWithFrame:self.frame mask:[UIImage imageNamed:@"TwitterEmptyView.png"] title:@"Twitter Unavailable" subtitle:subtitle];
	emptyView.subtitle.numberOfLines = 2;
	emptyView.subtitle.lineBreakMode = UILineBreakModeWordWrap;
	emptyView.subtitle.font = [emptyView.subtitle.font fontWithSize:12];
	emptyView.title.font = [emptyView.title.font fontWithSize:22];
	emptyView.subtitle.clipsToBounds = NO;
	emptyView.title.clipsToBounds = NO;
	[self addSubview:emptyView];
	[emptyView release];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)identifier{
	//
	if (aLoadType == refreshStatuses) {
		if(statusMessages){
            [statusMessages release];
        }
        statusMessages = [statuses retain];
		
		[self reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
		if ([self numberOfRowsInSection:0] > 0) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
			[self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
		}
	}
	else if (aLoadType == downloadMoreStatuses){
		
        NSArray *newStatuses;
		if(statusMessages){
            newStatuses = [statusMessages arrayByAddingObjectsFromArray:statuses];
            [statusMessages release];
        }
        else{
            newStatuses = statuses;
        }
        statusMessages = [newStatuses retain];
		
		
		//animate in the new cells
		int indexOfFirstNewMessage = [statusMessages count] - [statuses count];
		NSMutableArray *tempIndexPaths = [NSMutableArray array];
		for(int i = indexOfFirstNewMessage ; i < [statusMessages count] ; i++){
            [tempIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
		NSArray *indexPathsToReload = [NSArray arrayWithArray:tempIndexPaths];
		[self insertRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationLeft];
		
	}
	
	if (!haveRequestedUserImage) {
		if ([statuses count] > 0) {
			NSDictionary *tweetData = [statuses objectAtIndex:0];
			NSDictionary *userData = [tweetData objectForKey:@"user"];
			NSString *userImageURL = [userData objectForKey:@"profile_image_url"];
			if (userImageURL) {
				downloadImageThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadUserImage:) object:userImageURL];
				[downloadImageThread start];
				[downloadImageThread release];
				haveRequestedUserImage = YES;
			}
			
		}
	}
    [self stopLoading];
	
}


-(void)downloadUserImage:(NSString *)imageURL{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
	UIImage *tempUserImage = [UIImage imageWithData:imgData];
	if (![[NSThread currentThread] isCancelled]) {
		if (tempUserImage) {
			self.userImage = tempUserImage;
            [self performSelectorOnMainThread:@selector(reloadTableViewAnimated) withObject:nil waitUntilDone:NO];
		}
		else {
			//the user doesn't have an image, so we'll stick to the default
            haveRequestedUserImage = YES;
		}
	}
	[pool release];
}

-(void)reloadTableViewAnimated{
    [self reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)identifier{
	//Not implemented
}
- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)identifier{
	//
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if (!statusMessages) {
		return 0;
	}
	return [statusMessages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
    //get the dictionary for this tweet
    NSDictionary *dict = [statusMessages objectAtIndex:indexPath.row];
    
    //get the timestamp
	NSString *timestampStr = [dict objectForKey:@"created_at"];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss +0000 yyyy"];
    NSDate *timestamp = [dateFormatter dateFromString:timestampStr];
	[dateFormatter release];
    
    
    //get the text
    NSString *text = [dict objectForKey:@"text"];
    
    //get the alignment
    TwitterTableViewCellAlignment alignment = TwitterTableViewCellAlignmentRight;
    if(indexPath.row%2 == 0){
        alignment = TwitterTableViewCellAlignmentLeft;
    }
    
    
    TwitterTableViewCell *cell = [[TwitterTableViewCell alloc] initWithTableView:self messageText:text timestamp:timestamp andAlignment:alignment];
    
    if (userImage) {
		cell.userIcon.image = userImage;
	}
	else {
		cell.userIcon.image = [UIImage imageNamed:@"FlyingWVSmall.png"];
	}

	
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	//NSLog(@"Row:%d Height:%.1f", indexPath.row, (cell.bubbleImageView.frame.size.height + cell.timestampLabel.frame.size.height + 5));
    
	return cell;
	
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSDictionary *dict = [statusMessages objectAtIndex:indexPath.row];
    NSString *text = [dict objectForKey:@"text"];
    float maximumWidth = [TwitterTableViewCell maximumTextWidthForWindowOfWidth:tableView.frame.size.width];
    CGSize textSize = [TwitterTableViewCell textSizeWithMessage:text andMaximumWidth:maximumWidth];
    CGSize bubbleSize = [TwitterTableViewCell bubbleSizeWithTextSize:textSize];
    float cellHeight = [TwitterTableViewCell cellHeightWithBubbleSize:bubbleSize];
    return cellHeight;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
}

- (void)dealloc {
    [downloadImageThread cancel];
	[userImage release];
	[twitterEngine closeAllConnections];
    [super dealloc];
}




@end

