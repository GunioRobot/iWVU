//
//  TwitterBubbleViewController.m
//  iWVU
//
//  Created by Jared Crawford on 10/4/09.
//  Copyright Jared Crawford 2009. All rights reserved.
//

#import "TwitterBubbleViewController.h"
#import "MGTwitterEngine.h"
#import "iWVUAppDelegate.h"

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

	
}


-(void)addHeaderAndFooterToTableView{
	UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
	refreshButton.frame = CGRectMake(0, 0, 70, 40);
	refreshButton.contentMode = UIViewContentModeTop;
	[refreshButton addTarget:self action:@selector(refreshTwitter) forControlEvents:UIControlEventTouchUpInside];
	self.tableView.tableHeaderView = refreshButton;
	
	
	UIButton *showMoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[showMoreButton setTitle:@"Show More" forState:UIControlStateNormal];
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
		
		/*
		int indexOfLastTweet = ([statusMessages count]-1);
		NSDictionary *aDict = [statusMessages objectAtIndex:indexOfLastTweet];
		/*
		for (NSString *key in aDict) {
			NSLog(@"%@:%@", key, [aDict objectForKey:key]);
		}
		
		
		unsigned long aTweetID = [[aDict objectForKey:@"id"] unsignedLongValue];
		//NSLog(@"%@", [aDict objectForKey:@"text"]);
		 */
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
}


- (void)dealloc {
    [super dealloc];
}



-(UIView *)createABubbleWithText:(NSString *)theText andType:(ChatBubbleType)type{
	
	int leftCap; 
	int topCap = 20;
	
	int padding[4] = {10, 20, 10, 10};//top, right, bottom, left
	
	if (type == ChatBubbleTypeBlue) {
		leftCap = 20;
		padding[1] += 10;
	}
	else {
		leftCap = 30;
		padding[3] += 10;
	}

	
	
	
	int width = [theText sizeWithFont:[UIFont systemFontOfSize:[UIFont labelFontSize]]].width;
	if (width > 250) {
		width = 250;
	}
	
	UILabel *theLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
	theLabel.backgroundColor = [UIColor clearColor];
	theLabel.numberOfLines = 0;
	theLabel.lineBreakMode = UILineBreakModeWordWrap;
	theLabel.text = theText;
	[theLabel sizeToFit];
	
	
	CGSize finalSize = CGSizeMake(theLabel.frame.size.width+padding[1]+padding[3], theLabel.frame.size.height+padding[0]+padding[2]);
	UIView *finalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, finalSize.width, finalSize.height)];

	
	NSString *imageName;
	if (type == ChatBubbleTypeBlue) {
		imageName = @"BlueBubble.png";
		theLabel.textColor = [UIColor colorWithRed:1 green:.8 blue:0 alpha:1];
	}
	else{
		imageName = @"YellowBubble.png";
		theLabel.textColor = [UIColor colorWithRed:0 green:.2 blue:.4 alpha:1];
	}
	
	
	UIImage *anImage = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
	UIImageView *imgView = [[UIImageView alloc] initWithImage:anImage];
	
	imgView.frame = finalView.frame;
	
	
	[finalView addSubview:imgView];
	[finalView addSubview:theLabel];
	theLabel.frame = CGRectMake(padding[3], padding[0], theLabel.frame.size.width, theLabel.frame.size.height);
	[theLabel release];
	[imgView release];
	[finalView autorelease];
	return finalView;
	

}





- (void)requestSucceeded:(NSString *)requestIdentifier{
	[self addHeaderAndFooterToTableView];
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
		
		for (NSIndexPath *indexPath in indexPathsToReload) {
			NSLog(@"Row:%d Section:%d" , indexPath.row , indexPath.section);
		}
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
	
	//Determine if there is a URL in the tweet
	//Do this first because indicator effects positioning
	int rightIndicatorWidth = 0;
	NSString *text = [[statusMessages objectAtIndex:indexPath.row] objectForKey:@"text"];
	UITableViewCell	*cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BlueBubble"] autorelease];
	for (NSString *substring in [text componentsSeparatedByString:@" "]) {
		if ([substring hasPrefix:@"http://"]) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			rightIndicatorWidth = 15;
		}
	}
	
	
	//Create the bubble and position it
	UIView *bubble = [bubbles objectAtIndex:indexPath.row];
	
	int screenWidth = self.view.frame.size.width;
	int pad = 0;
	int bubbleWidth = bubble.frame.size.width;
	int bubbleHeight = bubble.frame.size.height;
	
	int bubbleXCoord;
	if (indexPath.row%2) {
		bubbleXCoord = screenWidth-bubbleWidth-pad-rightIndicatorWidth;
	}
	else {
		bubbleXCoord = pad;
	}
	
	bubble.frame = CGRectMake(bubbleXCoord,5, bubbleWidth, bubbleHeight);
	
	
	[cell.contentView addSubview:bubble];
	//cell.backgroundView = bubble;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	
	
	return cell;
	
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	UIView *bubble = [bubbles objectAtIndex:indexPath.row];
	return bubble.frame.size.height+10;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryDisclosureIndicator ) {
		NSString *text = [[statusMessages objectAtIndex:indexPath.row] objectForKey:@"text"];
		for (NSString *substring in [text componentsSeparatedByString:@" "]) {
			if ([substring hasPrefix:@"http://"]) {
				iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
				[AppDelegate loadWebViewWithURL:substring andTitle:substring];
				
			}
		}
	}
	
}

@end
