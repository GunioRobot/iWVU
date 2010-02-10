//
//  AthleticScoresViewController.m
//  iWVU
//
//  Created by Jared Crawford on 12/18/09.
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

#import "AthleticScoresViewController.h"


@implementation AthleticScoresViewController

@synthesize theScoresTableView;
@synthesize thePhotoView;
@synthesize theTeam;
@synthesize scoreData;
@synthesize currentGameData;


-(id)init{
	self = [[AthleticScoresViewController alloc] initWithNibName:@"AthleticScoresViewController" bundle:nil];
	return self;
}

-(id)initWithDictionary:(NSDictionary *)dict{
	[self init];
	self.currentGameData = dict;
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

	
	
	//set up the score section
	theScoresTableView.backgroundColor = [UIColor clearColor];
	theScoresTableView.delegate = self;
	theScoresTableView.dataSource = self;
	
	//set up the photo section
	thePhotoView.viewDelegate = self;
	thePhotoViewData = [[AthleticPhotoData alloc] init];
	thePhotoView.dataSource = thePhotoViewData;
	[thePhotoView setNumberOfImages:5];
	
	
	
	
	
	/*
	
	CALayer *layer = theScoresTableView.layer;
	CATransform3D rotationAndPerspectiveTransform = CATransform3DMakeRotation(60.0f * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
	//rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 1.0f, 1.0f, 5.0f);
	layer.transform = rotationAndPerspectiveTransform;
	
	*/
	NSLog(@"View Loaded");
	
}




//OpenFlow Delegate

- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index{
	
}
- (void)openFlowView:(AFOpenFlowView *)openFlowView didTap:(int)index{
	
}
- (void)openFlowView:(AFOpenFlowView *)openFlowView didDoubleTap:(int)index{
	
}
- (void)openFlowViewAnimationDidBegin:(AFOpenFlowView *)openFlowView{
	
}
- (void)openFlowViewAnimationDidEnd:(AFOpenFlowView *)openFlowView{
	
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
	NSDictionary *gameData = currentGameData;
	if (gameData == nil) {
		gameData = [scoreData.downloadedGameData objectAtIndex:indexPath.row];
	}
	SingleGameScore *scoreView = [[SingleGameScore alloc] initWithDictionary:gameData];
	return scoreView;
}





/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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


@end
