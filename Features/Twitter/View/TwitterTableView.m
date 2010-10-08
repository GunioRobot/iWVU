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

-(id)initWithFrame:(CGRect)frame{
	
	if (self = [super initWithFrame:frame style:UITableViewStylePlain]) {
		self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
		self.delegate = self;
		self.dataSource = self;
		
		aLoadType = refreshStatuses;
		currentPage = 1;
		self.separatorStyle = UITableViewCellSeparatorStyleNone;
		iconDB = [[TwitterUserIconDB alloc] initWithIconDelegate: self];
		self.backgroundColor = [UIColor viewBackgroundColor];
		twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
		
		anErrorHasOccured = NO;
        twitterListName = nil;
		twitterUserName = nil;
		
		
		return self;
	}
	return nil;
}


// pasteboard.
- (BOOL)canBecomeFirstResponder {
	return YES;
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
	
	if (twitterListName) {
		[twitterEngine getStatusesFromList:twitterListName onAccount:twitterUserName];
	}
	else if(twitterUserName){
		[twitterEngine getUserTimelineFor:twitterUserName sinceID:0 startingAtPage:currentPage count:NumberOfMessageToDowload];
	}
}

-(void)setTwitterUserName:(NSString *)userName{
	[twitterUserName release];
	[twitterListName release];
	twitterListName = nil;
	if (userName) {
		twitterUserName = [userName retain];
		[self refresh];
	}
	else {
		twitterUserName = nil;
	}
	
}


-(void)setTwitterList:(NSString *)listName onAccount:(NSString *)accountName{
	[twitterUserName release];
	[twitterListName release];
	if (listName && accountName) {
		twitterUserName = [accountName retain];
		twitterListName = [listName retain];
		[self refresh];
	}
	else {
		twitterUserName = nil;
		twitterListName = nil;
	}
}


-(NSString *)getUserName{
	if (twitterListName) {
		return [NSString stringWithFormat:@"%@/%@", twitterUserName, twitterListName];
	}
	return twitterUserName;
}

-(void)downloadMoreFromTwitter{
	
	//currently does not work for lists
	
	aLoadType = downloadMoreStatuses;
	currentPage++;
	if ([statusMessages count] > 0) {
		[twitterEngine getUserTimelineFor:twitterUserName sinceID:0 startingAtPage:currentPage count:NumberOfMessageToDowload];
	}
}


- (void)requestSucceeded:(NSString *)requestIdentifier{
	
	//make sure there's not an error view obstructing the view
	if (anErrorHasOccured) {
		for (UIView *subview in self.subviews) {
			if ([subview isKindOfClass:[TKEmptyView class]]) {
				[subview removeFromSuperview];
			}
		}
	}
	anErrorHasOccured = NO;
	
	[self addFooterToTableView];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.backgroundColor = [UIColor viewBackgroundColor];
}


- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error{
	
	if(!anErrorHasOccured){
		NSString *subtitle = @"Try again later.";
		NSLog(@"%@", error);
		if([error code] == -1009){
			subtitle = @"An internet connection is required";
		}
		TKEmptyView *emptyView = [[TKEmptyView alloc] initWithFrame:self.frame mask:[UIImage imageNamed:@"TwitterEmptyView.png"] title:@"Twitter Unavailable" subtitle:subtitle];
		
		[self addSubview:emptyView];
		[emptyView release];
	}
	self.backgroundColor = [UIColor whiteColor];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	anErrorHasOccured = YES;
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
	[self reloadTableViewAnimated];
    [self stopLoading];
	
}


-(void)reloadTableViewAnimated{
	NSIndexSet *allSections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self numberOfSectionsInTableView:self])];
    [self reloadSections:allSections withRowAnimation:UITableViewRowAnimationFade];
}

-(void)twitterUserIconDBUpdated{
	[self reloadTableViewAnimated];
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
    
    NSDictionary *userData = [dict valueForKey:@"user"];
    cell.userIcon.image = [iconDB userIconWithUserData:userData];

	
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
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSDictionary *dict = [statusMessages objectAtIndex:indexPath.row];
    NSString *text = [dict objectForKey:@"text"];
	
	NSArray *messageComponents = [text componentsSeparatedByString:@" "];
	NSMutableArray *urlComponents = [NSMutableArray array];
	for (NSString *component in messageComponents) {
		if ([component hasPrefix:@"http://"]) {
			[urlComponents addObject:component];
		}
	}
	if ([urlComponents count] > 0) {
		
		NSString *cancelButtonTitle = nil;
		if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
			cancelButtonTitle = @"cancel";
		}
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Open URL" delegate:self cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:nil otherButtonTitles:nil];
		for (NSString *component in urlComponents) {
			[actionSheet addButtonWithTitle:component];
		}
		[actionSheet showFromRect:[self rectForRowAtIndexPath:indexPath] inView:self animated:YES];
	}
	else {
		textOfSelectedTweet = [text retain];
		[self becomeFirstResponder];
		UIMenuController *copyMenu = [UIMenuController sharedMenuController];
		[copyMenu setTargetRect:[self rectForRowAtIndexPath:indexPath] inView:self];
		[copyMenu setMenuVisible:YES animated:YES];
	}
}


//for UIMenuController
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	if (action == @selector(copy:)) {
		return YES;
	}
	return [super canPerformAction:action withSender:sender];
}



- (void)copy:(id)sender {
	
	// Get the General pasteboard and the current tile.
	UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];	
	gpBoard.string = textOfSelectedTweet;
	[textOfSelectedTweet release];
	textOfSelectedTweet = nil;
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex != actionSheet.cancelButtonIndex) {
		NSString *url = [actionSheet buttonTitleAtIndex:buttonIndex];
		OPENURL(url);
	}
}

- (void)dealloc {
	[iconDB dealloc];
	[twitterEngine closeAllConnections];
	[twitterEngine release];
	[twitterUserName release];
	[twitterListName release];
    [super dealloc];
}




@end

