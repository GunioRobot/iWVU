//
//  AthleticScoresViewController.m
//  iWVU
//
//  Created by Jared Crawford on 12/18/09.
//  Copyright Jared Crawford 2010. All rights reserved.
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

#import "AthleticScoresViewController.h"
#import "SingleGameScore.h"
#import "UIImage+Resize.h"
#import "AFOpenFlowView.h"


@implementation AthleticScoresViewController

@synthesize theScoresTableView;
@synthesize thePhotoView;
@synthesize theTeam;
@synthesize scoreData;
@synthesize currentGameData;
@synthesize delayTimer;


-(id)init{
	self = [[AthleticScoresViewController alloc] initWithNibName:@"AthleticScoresViewController" bundle:nil];
	return self;
}

-(id)initWithTeam:(AthleticsTeam)team{
	[self init];
	self.theTeam = team;
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (theTeam == AthleticsTeamFootball) {
		theBackground.image = [UIImage imageNamed:@"TurfFadeToBlack.png"];
	}
	else {
		theBackground.image = [UIImage imageNamed:@"HardwoodFadeToBlack.png"];
	}

	gameIndex = 0;
	
	//set up the score section
	theScoresTableView.backgroundColor = [UIColor clearColor];
	theScoresTableView.delegate = self;
	theScoresTableView.dataSource = self;
	
	//set up the logo section
	thePhotoView.viewDelegate = self;
	thePhotoView.dataSource = self;
	[thePhotoView setNumberOfImages:1];
	
	self.scoreData = [[AthleticScoreData alloc] initWithTeam:theTeam];
	scoreData.delegate = self;
	[scoreData requestScoreData];


	loadingView  = [[TKLoadingView alloc] initWithTitle:@"Loading Live Score Data"];
	[self.view addSubview:loadingView];
	[loadingView startAnimating];
	//center it over the table view, so it shows on the "floor" surface
	//we don't want it centered on the screen, that would be black on black
	float x = theScoresTableView.frame.origin.x+(theScoresTableView.frame.size.width/2);
	float y = theScoresTableView.frame.origin.y+(theScoresTableView.frame.size.height/2);
	loadingView.center = CGPointMake(x,y);
	
}

-(void)refreshTableView{
	//[theScoresTableView reloadData];
	self.delayTimer = nil;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDelegate:theScoresTableView];
	
	[UIView setAnimationWillStartSelector:@selector(reloadData)];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:theScoresTableView cache:NO];
	
	
	[UIView setAnimationDuration:1];
	
	[UIView commitAnimations];
}


//OpenFlow Delegate

- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index{
	gameIndex = index;
	[delayTimer invalidate];
	self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshTableView) userInfo:nil repeats:NO];
	
	
}
- (void)openFlowView:(AFOpenFlowView *)openFlowView didTap:(int)index{
	
}
- (void)openFlowView:(AFOpenFlowView *)openFlowView didDoubleTap:(int)index{
	
}
- (void)openFlowViewAnimationDidBegin:(AFOpenFlowView *)openFlowView{
	
}
- (void)openFlowViewAnimationDidEnd:(AFOpenFlowView *)openFlowView{
	
}



//OpenFlow Data Sourcs

- (UIImage *)scale:(UIImage *)image toSize:(CGSize)size{
	UIGraphicsBeginImageContext(size);
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return scaledImage;
}


-(UIImage *)getImageForIndex:(int)index{
	UIImage *anImage;
	
	if(([scoreData.downloadedGameData count]>index)&&([scoreData.homeLogos count]>index)){
		
		
		NSDictionary *dict = [scoreData.downloadedGameData objectAtIndex:index];
		if([@"West Virginia" isEqualToString:[scoreData stringForKey:@"home" inDict:dict]]){
			anImage = [scoreData.awayLogos objectAtIndex:index];
		}
		else{
			anImage = [scoreData.homeLogos objectAtIndex:index];
		}
	}
	else {
		anImage = [self defaultImage];
	}
	
	anImage = [self scale:anImage toSize:CGSizeMake(OPENFLOW_IMAGE_SIZE, OPENFLOW_IMAGE_SIZE)];
	return anImage;
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index{
	
	UIImage *anImage = [self getImageForIndex:index];
	
	[openFlowView setImage:anImage forIndex:index];
}

- (UIImage *)defaultImage{
	if(theDefaultImage){
		return theDefaultImage;
	}
	

	theDefaultImage = [UIImage imageNamed:@"FlyingWVDefaultBig.png"];
	[theDefaultImage retain];
	return theDefaultImage;
}





//Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 208;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 0;
}





//Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSDictionary *gameData = [scoreData.downloadedGameData objectAtIndex:gameIndex];
	if([gameData count] > 0){
		
		if(loadingView){
			[loadingView removeFromSuperview];
			[loadingView release];
			loadingView = nil;
		}
		
		
		UIImage *homeLogo;
		UIImage *awayLogo;
		if([scoreData.homeLogos count] > gameIndex){
			homeLogo = [scoreData.homeLogos objectAtIndex:gameIndex];
			awayLogo = [scoreData.awayLogos objectAtIndex:gameIndex];
		}
		else{
			homeLogo = [UIImage imageNamed:@"NCAA_Logo.png"];
			awayLogo = homeLogo;
		}
		
		
		SingleGameScore *scoreView = [[SingleGameScore alloc] initWithDictionary:gameData homeLogo:homeLogo awayLogo:awayLogo];
		return [scoreView autorelease];
	}
	
	//the view isn't finished loading yet, so I'm going to return an empty cell
	return [[[UITableViewCell alloc] init] autorelease];
}







-(void)newScoreDataAvailable{
	[self reloadOpenFlowView];
	[theScoresTableView reloadData];
}


-(void)reloadOpenFlowView{
	[thePhotoView setNumberOfImages:[scoreData.downloadedGameData count]];
	for(int i=0;i<[scoreData.downloadedGameData count];i++){
		UIImage *anImage = [self getImageForIndex:i];
		[thePhotoView setImage:anImage forIndex:i];
	}
	
	
	gameIndex = [scoreData.downloadedGameData count]-1;
	//a dirty hack forcing OpenFlow to redraw covers 
	if((gameIndex-1)>0){
		[thePhotoView setSelectedCover:gameIndex-1];
	}
	[thePhotoView setSelectedCover:gameIndex];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	[delayTimer invalidate];
	self.delayTimer = nil;
	
}

- (void)viewWillDisappear:(BOOL)animated{
	[scoreData cancelAllDownloads];
}


- (void)dealloc {
    [super dealloc];
}


@end
