//
//  TwitterTableView.m
//  iWVU
//
//  Created by Jared Crawford on 6/26/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "TwitterTableView.h"

#import "MGTwitterEngine.h"
#import "NSDate+Helper.h"
#import <Three20/Three20.h>
#import "TTStyledTextLabel+URL.h"
#import <TapkuLibrary/TapkuLibrary.h>

#define NumberOfMessageToDowload 0


typedef enum{
	ChatBubbleTypeBlue,
	ChatBubbleTypeYellow
} ChatBubbleType;


@implementation TwitterTableView

@synthesize twitterUserName;

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
		
		return self;
	}
	return nil;
}

-(void)addHeaderAndFooterToTableView{
	UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
	refreshButton.frame = CGRectMake(0, 0, 70, 40);
	refreshButton.contentMode = UIViewContentModeTop;
	[refreshButton addTarget:self action:@selector(refreshTwitter) forControlEvents:UIControlEventTouchUpInside];
	self.tableHeaderView = refreshButton;
	
	
	UIButton *showMoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[showMoreButton setTitle:@"Load More" forState:UIControlStateNormal];
	showMoreButton.frame = CGRectMake(0, 0, 70, 40);
	showMoreButton.contentMode = UIViewContentModeTop;
	[showMoreButton addTarget:self action:@selector(downloadMoreFromTwitter) forControlEvents:UIControlEventTouchUpInside];
	self.tableFooterView = showMoreButton;
}

-(void)refreshTwitter{
	aLoadType = refreshStatuses;
	currentPage = 1;
	[twitterEngine getUserTimelineFor:twitterUserName sinceID:0 startingAtPage:currentPage count:NumberOfMessageToDowload];
}

-(void)downloadMoreFromTwitter{
	aLoadType = downloadMoreStatuses;
	currentPage++;
	if ([statusMessages count] > 0) {
		[twitterEngine getUserTimelineFor:twitterUserName sinceID:0 startingAtPage:currentPage count:NumberOfMessageToDowload];
	}
}

-(void)setTwitterUserName:(NSString *)name{
	twitterUserName = [name retain];
	[self refreshTwitter];
}



-(UIView *)createABubbleWithText:(NSString *)theText andType:(ChatBubbleType)type{
	
	int topCap = 20;
	int leftCap = 20;
	int leftTextBufferFromBubble = 15;
	if (type == ChatBubbleTypeYellow) {
		leftCap = 30;
		leftTextBufferFromBubble = 22;
	}
	
	
	float widthOfBubble = self.frame.size.width*.7;
	
	CGSize labelSize = [theText sizeWithFont:[UIFont systemFontOfSize:[UIFont labelFontSize]] constrainedToSize:CGSizeMake(widthOfBubble,1000)];
	
	
	
	TTStyledTextLabel* theLabel = [[TTStyledTextLabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
	theLabel.contentInset = UIEdgeInsetsMake(8, leftTextBufferFromBubble, 10, 13);
	theLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
	theLabel.text = [TTStyledText textWithURLs:theText lineBreaks:YES];
	if(theLabel.text == nil){
		theLabel.text = [TTStyledText textWithURLs:theText lineBreaks:YES];
	}
	theLabel.backgroundColor = [UIColor clearColor];
	[theLabel sizeToFit];
	
	
	
	CGSize finalSize = CGSizeMake(theLabel.frame.size.width, theLabel.frame.size.height);
	UIView *finalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, finalSize.width, finalSize.height)];
	
	
	NSString *imageName;
	if (type == ChatBubbleTypeBlue) {
		imageName = @"BlueBubble.png";
		theLabel.textColor = [UIColor WVUGoldColor];
	}
	else{
		imageName = @"YellowBubble.png";
		theLabel.textColor = [UIColor WVUBlueColor];
	}
	
	
	UIImage *anImage = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
	UIImageView *imgView = [[UIImageView alloc] initWithImage:anImage];
	imgView.opaque = YES;
	imgView.backgroundColor = self.backgroundColor;
	
	imgView.frame = finalView.frame;
	
	
	[finalView addSubview:imgView];
	[finalView addSubview:theLabel];
	[theLabel release];
	[imgView release];
	[finalView autorelease];
	return finalView;
}





- (void)requestSucceeded:(NSString *)requestIdentifier{
	[self addHeaderAndFooterToTableView];
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
		statusMessages = [statuses retain];
		
		
		NSMutableArray *tempBubbles = [NSMutableArray array];
		for (NSDictionary *aDict in statuses) {
			
			NSString *text = [aDict objectForKey:@"text"];
			ChatBubbleType typeOfBubble;
			if ([tempBubbles count]%2) {
				typeOfBubble = ChatBubbleTypeBlue;
			}
			else {
				typeOfBubble = ChatBubbleTypeYellow;
			}
			
			UIView *bubble = [self createABubbleWithText:text andType:typeOfBubble];
			bubble.frame = CGRectMake(0, 0, bubble.frame.size.width, bubble.frame.size.height);
			[tempBubbles addObject:bubble];
		}
		
		if ([bubbles retainCount] != 0) {
			[bubbles release];
		}
		bubbles = [[NSArray arrayWithArray:tempBubbles] retain];
		
		[self reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
		if ([self numberOfRowsInSection:0] > 0) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
			[self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
		}
	}
	else if (aLoadType == downloadMoreStatuses){
		
		int indexOfFirstNewMessage = [statusMessages count];
		NSMutableArray *tempStatusMessages = [NSMutableArray arrayWithArray:statusMessages];
		NSMutableArray *tempBubbles = [NSMutableArray arrayWithArray:bubbles];
		for (NSDictionary *aDict in statuses) {
			NSString *text = [aDict objectForKey:@"text"];
			ChatBubbleType typeOfBubble;
			if ([tempBubbles count]%2) {
				typeOfBubble = ChatBubbleTypeBlue;
			}
			else {
				typeOfBubble = ChatBubbleTypeYellow;
			}
			
			UIView *bubble = [self createABubbleWithText:text andType:typeOfBubble];
			bubble.frame = CGRectMake(0, 0, bubble.frame.size.width, bubble.frame.size.height);
			[tempBubbles addObject:bubble];
			[tempStatusMessages addObject:aDict];
		}
		
		if([bubbles retainCount]!=0) {
			[bubbles release];
		}
		if ([statusMessages retainCount]!=0) {
			[statusMessages release];
		}
		
		bubbles = [[NSArray arrayWithArray:tempBubbles] retain];
		statusMessages = [[NSArray arrayWithArray:tempStatusMessages] retain];
		
		
		
		
		NSMutableArray *tempIndexPaths = [NSMutableArray array];
		int currentRow = indexOfFirstNewMessage;
		while([statusMessages count] > currentRow) {
			[tempIndexPaths addObject:[NSIndexPath indexPathForRow:currentRow inSection:0]];
			currentRow++;
		}
		NSArray *indexPathsToReload = [NSArray arrayWithArray:tempIndexPaths];
		
		
		
		
		
		[self insertRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationLeft];
		
	}
	
	
	
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
	
	UITableViewCell	*cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BlueBubble"] autorelease];
	
	
	
	
	//Create the bubble and position it
	UIView *bubble = [bubbles objectAtIndex:indexPath.row];
	
	float screenWidth = self.frame.size.width;
	float pad = 0;

	
	float bubbleWidth = bubble.frame.size.width;
	float bubbleHeight = bubble.frame.size.height;
	
	float bubbleXCoord;
	if (indexPath.row%2) {
		bubbleXCoord = screenWidth-bubbleWidth-pad;
	}
	else {
		bubbleXCoord = pad;
	}
	
	bubble.frame = CGRectMake(bubbleXCoord,18, bubbleWidth, bubbleHeight);
	
	[cell.contentView addSubview:bubble];
	//cell.backgroundView = bubble;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	
	//Timestamp label
	
	NSDictionary *dict = [statusMessages objectAtIndex:indexPath.row];
	
	NSString *timestampStr = [dict objectForKey:@"created_at"];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss +0000 yyyy"];
    NSDate *timestamp = [dateFormatter dateFromString:timestampStr];
	
	
	
	
	UILabel *timestampLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	timestampLabel.font = [UIFont systemFontOfSize:11];
	timestampLabel.text = [timestamp stringDaysAgo];
	if ([timestampLabel.text isEqualToString:@"Today"]) {
		NSString *todaysTime = [NSString stringWithFormat:@"Today at %@", [NSDate stringForDisplayFromDate:timestamp]];
		timestampLabel.text = todaysTime ;
	}
	timestampLabel.adjustsFontSizeToFitWidth = YES;
	timestampLabel.backgroundColor = tableView.backgroundColor;
	timestampLabel.contentMode = UIViewContentModeTop;
	timestampLabel.textColor = [UIColor grayColor];
	
	[cell.contentView addSubview:timestampLabel];
	[cell.contentView sendSubviewToBack:timestampLabel];
	[timestampLabel release];
	
	float timestampWidth = [timestampLabel.text sizeWithFont:timestampLabel.font].width;
	float timestampHeight = 15;
	float cellWidth = self.frame.size.width;
	float timestampY = 1;
	
	CGRect timestampFrame = CGRectMake((cellWidth - timestampWidth)/2, timestampY, timestampWidth, timestampHeight);
	timestampLabel.frame = timestampFrame;
	
	
	return cell;
	
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	UIView *bubble = [bubbles objectAtIndex:indexPath.row];
	return bubble.frame.size.height+20;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
}




- (void)dealloc {
	[userImage release];
	[twitterEngine closeAllConnections];
    [super dealloc];
}


@end

