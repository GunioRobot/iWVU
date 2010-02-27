//
//  TwitterBubbleViewController.m
//  iWVU
//
//  Created by Jared Crawford on 10/4/09.
//  Copyright Jared Crawford 2009. All rights reserved.
//


/*
 Copyright (c) 2009 Jared Crawford
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 The trademarks owned or managed by the West Virginia 
 University Board of Governors (WVU) are used under agreement 
 between the above copyright holder(s) and WVU. The West 
 Virginia University Board of Governors maintains ownership of all 
 trademarks. Reuse of this software or software source code, in any 
 form, must remove all references to any trademark owned or 
 managed by West Virginia University.
 */ 

#import "TwitterBubbleViewController.h"
#import "MGTwitterEngine.h"
#import "NSDate+Helper.h"
#import <Three20/Three20.h>
#import "TTStyledLinkNode+URL.h"

#define NumberOfMessageToDowload 0


typedef enum{
	ChatBubbleTypeBlue,
	ChatBubbleTypeYellow
} ChatBubbleType;


@implementation TwitterBubbleViewController


@synthesize twitterUserName;


-(id)initWithUserName:(NSString *)aUserName{
	if (self = [self initWithStyle:UITableViewStylePlain]) {
		self.twitterUserName = aUserName;
	} ;
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	aLoadType = refreshStatuses;
	currentPage = 1;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	//219, 226, 237
	self.tableView.backgroundColor =[UIColor colorWithRed:(219./255) green:(226./255) blue:(237./255) alpha:1];
	
	twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
	[twitterEngine getUserTimelineFor:twitterUserName sinceID:0 startingAtPage:currentPage count:NumberOfMessageToDowload];
	
	
	
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(replyToUser)];
	self.navigationItem.rightBarButtonItem = barButton;
	[barButton release];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)viewDidAppear:(BOOL)animated{
	NSString *pageName = [NSString stringWithFormat:@"/Main/TwitterList/%@", twitterUserName];
	NSError *anError;
	[[GANTracker sharedTracker] trackPageview:pageName withError:&anError];
}

-(void)viewDidDisappear:(BOOL)animated{
	aLoadType = noMoreLoading;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[twitterEngine closeAllConnections];
}

-(void)addHeaderAndFooterToTableView{
	UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
	refreshButton.frame = CGRectMake(0, 0, 70, 40);
	refreshButton.contentMode = UIViewContentModeTop;
	[refreshButton addTarget:self action:@selector(refreshTwitter) forControlEvents:UIControlEventTouchUpInside];
	self.tableView.tableHeaderView = refreshButton;
	
	
	UIButton *showMoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[showMoreButton setTitle:@"Load More" forState:UIControlStateNormal];
	showMoreButton.frame = CGRectMake(0, 0, 70, 40);
	showMoreButton.contentMode = UIViewContentModeTop;
	[showMoreButton addTarget:self action:@selector(downloadMoreFromTwitter) forControlEvents:UIControlEventTouchUpInside];
	self.tableView.tableFooterView = showMoreButton;
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





- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}



- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)dealloc {
    [super dealloc];
}



-(UIView *)createABubbleWithText:(NSString *)theText andType:(ChatBubbleType)type{
	
	int topCap = 20;
	int leftCap = 20;
	int leftTextBufferFromBubble = 15;
	if (type == ChatBubbleTypeYellow) {
		leftCap = 30;
		leftTextBufferFromBubble = 22;
	}
	
	CGSize labelSize = [theText sizeWithFont:[UIFont systemFontOfSize:[UIFont labelFontSize]] constrainedToSize:CGSizeMake(250,500)];
	
	
	
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
	NSString *errorMessage = [error localizedDescription];
	UIAlertView *err = [[UIAlertView alloc] initWithTitle:nil message:errorMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[err show];
	[err release];
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
		
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
		if ([self.tableView numberOfRowsInSection:0] > 0) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
			[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
		
		
		
		
		
		[self.tableView insertRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationLeft];
		
		
		
		
		
		//[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
	}

	
	
}



- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)identifier{
	//Not implemented
}
- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)identifier{
	//
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
	
	int screenWidth = self.view.frame.size.width;
	int pad = 0;
	int bubbleWidth = bubble.frame.size.width;
	int bubbleHeight = bubble.frame.size.height;
	
	int bubbleXCoord;
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
	NSDate *timestamp = [dict objectForKey:@"created_at"];
	
	
	
	
	
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
	
	int timestampWidth = [timestampLabel.text sizeWithFont:timestampLabel.font].width;
	int timestampHeight = 15;
	int cellWidth = 320;
	int timestampY = 1;
	
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








-(void)replyToUser{
	NSString *aTitle = [NSString stringWithFormat:@"Reply to @%@", twitterUserName];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:aTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Echofon", @"Tweetie", @"Twittelator Pro", @"Twitterriffic", @"Web", nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	NSString *chosenTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	if (buttonIndex != actionSheet.cancelButtonIndex) {
		NSString *atUsername = [NSString stringWithFormat:@"%@%@",@"@",twitterUserName];
		NSString *url = @"";
		if([chosenTitle isEqualToString:@"Echofon"]){
			url = [NSString stringWithFormat:@"twitterfon:///post?%@",atUsername];
		}
		else if([chosenTitle isEqualToString:@"Tweetie"]){
			url = [NSString stringWithFormat:@"tweetie:///post?message=%@", atUsername];
		}
		else if([chosenTitle isEqualToString:@"Web"]){
			url = [NSString stringWithFormat:@"http://twitter.com/%@",twitterUserName];
		}
		else if([chosenTitle isEqualToString:@"Twittelator Pro"]){
			url = [NSString stringWithFormat:@"twit:///post?message=%20&isDirect=0&replyToScreenName=%@",twitterUserName];
		}
		else if([chosenTitle isEqualToString:@"Twitterriffic"]){
			url = [NSString stringWithFormat:@"twitterrific:///post?message=%@",atUsername];
		}
		
		[AppDelegate callExternalApplication:chosenTitle withURL:url];
	}
}

@end
