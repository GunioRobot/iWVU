//
//  U92Controller.m
//  iWVU
//
//  Created by Jared Crawford on 6/15/09.
//  Copyright 2009 Jared Crawford. All rights reserved.
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

#import <AVFoundation/AVFoundation.h>

#import "U92Controller.h"
#import "BuildingLocationController.h"
#import "Reachability.h"


@implementation U92Controller



- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	//self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableBackBlue.png"]]; 
}

-(void)viewDidAppear:(BOOL)animated{
	NSError *anError;
	[[GANTracker sharedTracker] trackPageview:@"/Main/U92" withError:&anError];
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 2;
			break;
		case 2:
			return 7;
			break;
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    iWVUAppDelegate *AppDelegate = [[UIApplication sharedApplication] delegate];
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	//cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"YellowSelected.png"]] autorelease];
	
	cell = [AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
	
    // Set up the cell...
	
	NSString *mainText = @"";
	NSString *subText = @"";
	
	switch (indexPath.section) {
		case 0:
			mainText = @"Listen Live";
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					mainText = @"U92 Website";
					break;
				case 1:
					mainText = @"Make a request";
					break;
			}
			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					mainText = @"Frequency";
					subText = @"91.7 FM";
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					break;
				case 1:
					mainText = @"Call Sign";
					subText = @"WWVU-FM";
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					break;
				case 2:
					mainText = @"Power";
					subText = @"2600 W";
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					break;
				case 3:
					mainText = @"Location";
					subText = @"Mountainlair";
					break;
				case 4:
					mainText = @"Phone";
					subText = @"(304) 293-3329";
					break;
				case 5:
					mainText = @"Fax";
					subText = @"(304) 293-7363";
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					break;
				case 6:
					mainText = @"Email";
					subText = @"u92@mail.wvu.edu";
					break;
			}
			break;
	}
	
	cell.textLabel.text = mainText;
	cell.detailTextLabel.text =subText; 
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	iWVUAppDelegate *AppDelegate = [[UIApplication sharedApplication] delegate];
	
	
	
	
	///////////////////
	/*
	UIView *myView = [tableView cellForRowAtIndexPath:indexPath].backgroundView;
	UIGraphicsBeginImageContext(myView.bounds.size);
	[myView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, NULL);
	

	*/
	
	
	//////////
	
	
	
	
	if (indexPath.section == 0){
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		
		
		
		
		
		
		
		NSString *path = @"157.182.129.241";
		
		
		[[Reachability sharedReachability] setHostName:path];
		
		NetworkStatus internetStatus = [[Reachability sharedReachability] remoteHostStatus];
		
		if ((internetStatus != ReachableViaWiFiNetwork) && (internetStatus != ReachableViaCarrierDataNetwork))
		{
			UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"An internet connection is required to stream U92." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[myAlert show];
			[myAlert release];
			path = @"";
		}
		else if(internetStatus == ReachableViaWiFiNetwork){
			path = @"http://157.182.129.241:554/u92Live-256k.m3u";
		}
		else{
			path = @"http://157.182.129.241:554/u92Live-32k-mono.m3u";
		}
		
		if([path isEqualToString:@""] == NO){
			loading = [[UIAlertView alloc] initWithTitle:nil message:@"Determining optimal network settings..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
			UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			activityView.frame = CGRectMake(139.0f-18.0f, 80.0f, 37.0f, 37.0f);
			[loading addSubview:activityView];
			[activityView startAnimating];
			[loading show];
			//[self performSelector:@selector(releaseAlert:) withObject:loading afterDelay:10];
		}
		
		NSURL *website =[NSURL URLWithString:path];
		if(!web){
			web = [[UIWebView alloc] initWithFrame:CGRectZero];
		}
		web.delegate = self;
		[web loadRequest:[NSURLRequest requestWithURL:website]];
		 /*
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(playerFinishedPlaying:)
													 name:MPMoviePlayerPlaybackDidFinishNotification object:player];
		  */
		
		
		
		
		/*
		MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:path]];
		if([player respondsToSelector:@selector(setOrientation:animated:)]){
			[player setOrientation:UIDeviceOrientationPortrait animated:NO];
		}
		 */

	}
	else if(indexPath.section == 1){
		//
		
		if(indexPath.row == 0){
			[AppDelegate loadWebViewWithURL:@"http://u92.wvu.edu" andTitle:@"U92 Website"];
		}
		else if(indexPath.row == 1){
			//
			[AppDelegate loadWebViewWithURL:@"http://u92.wvu.edu/contact.cfm" andTitle:@"Requests"];
		}
	}
	else if(indexPath.section == 2){
		if(indexPath.row == 3){		
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			BuildingLocationController *theBuildingView = [[BuildingLocationController alloc] initWithNibName:@"BuildingLocation" bundle:nil];
			NSString *buildingName = @"Mountainlair";
			theBuildingView.buildingName = buildingName;
			theBuildingView.navigationItem.title = buildingName;
			[self.navigationController pushViewController:theBuildingView animated:YES];
			[theBuildingView release];
		}
		else if(indexPath.row == 4){
			NSString *phoneNum = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
			[AppDelegate callPhoneNumber:phoneNum];
		}
		else if(indexPath.row == 6){
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			[AppDelegate composeEmailTo:@"u92@mail.wvu.edu" withSubject:nil andBody:nil];
		}
	}
}

-(void)releaseAlert:(UIAlertView *)alert{
	[alert dismissWithClickedButtonIndex:0 animated:YES];
	[alert release];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
	[self performSelector:@selector(releaseAlert:) withObject:loading afterDelay:5];
	//[self releaseAlert:loading];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	if(web){
		[web release];
	}
    [super dealloc];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 0){
		return nil;
	}
	else if(section == 1){
		return @"Links";
	}
	else if(section == 2){
		return @"Information";
	}
	return nil;
}



@end

