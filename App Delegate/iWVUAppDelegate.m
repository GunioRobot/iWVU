//
//  iWVUAppDelegate.m
//  iWVU
//
//  Created by Jared Crawford on 6/9/09.
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




#import "iWVUAppDelegate.h"

#import "MainScreen.h"

#import <MessageUI/MessageUI.h>

#define IMAGE_CAP_LEFT 30
#define IMAGE_CAP_TOP 25 


@implementation iWVUAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize streamer;
@synthesize splitViewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options {    

	//iWVU Specific
	//[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PRTQuietHours" ofType:@"plist"]]];
	
    
    //A fix for iCloud Support
    [self cleanUpDocumentsFolder];
    
	MainScreen *theFirstPage = [[MainScreen alloc] init];
	theFirstPage.navigationItem.title = @"iWVU";
	UIImage *flyingWV = [UIImage imageNamed:@"WVUTitle.png"];
	theFirstPage.navigationItem.titleView = [[UIImageView alloc] initWithImage:flyingWV];
	theFirstPage.navigationItem.hidesBackButton = YES;
    
	self.navigationController = [[UINavigationController alloc] initWithRootViewController:theFirstPage];
    navigationController.navigationBar.tintColor = [UIColor applicationPrimaryColor];
    
    
	[window addSubview:navigationController.view];
    [window makeKeyAndVisible];
	
	return YES;
}








#pragma mark Configure UITableViewCells

-(BOOL)shouldUsePrimaryColorShemeForIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView{
	
	//////////////////
	// Alternate Rows
	//////////////////
	
	/*
	 int i = 0;
	 for(int sect = 0; sect<indexPath.section;sect++){
	 i += [tableView.dataSource tableView:tableView numberOfRowsInSection:sect];
	 }
	 i += indexPath.row;
	 if( i%2 == 0){
	 return NO;
	 }
	 return YES;
	 */
	
	
	//////////////////
	// Alternate Sections
	//////////////////
	
	
	
	if(indexPath.section %2 == 0){
		return YES;
	}
	return NO;
	
	
	//////////////////
	// Just Use One
	//////////////////
	
	
	return YES;
	
}


-(UIImageView *)getCellSelectedBackgroundForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
	
	BOOL isOdd = [self shouldUsePrimaryColorShemeForIndexPath:indexPath forTableView:tableView];
	
	NSString *imageName;
	
	
	if(isOdd){
		if(indexPath.row == 0){
			if([tableView numberOfRowsInSection:indexPath.section] == 1){
				imageName = @"WVUSingleGold.png";
			}
			else{
				imageName = @"WVUTopGold.png";
			}
		}
		else if(indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1)){
			imageName = @"WVUBottomGold.png";
		}
		else {
			imageName = @"WVUMiddleGold.png";
		}
	}
	else{
		if(indexPath.row == 0){
			if([tableView numberOfRowsInSection:indexPath.section] == 1){
				imageName = @"WVUSingleBlue.png";
			}
			else{
				imageName = @"WVUTopBlue.png";
			}
		}
		else if(indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1)){
			imageName = @"WVUBottomBlue.png";
		}
		else {
			imageName = @"WVUMiddleBlue.png";
		}
	}
	
	UIImage *anImage = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:IMAGE_CAP_LEFT topCapHeight:IMAGE_CAP_TOP];
	return [[UIImageView alloc] initWithImage:anImage];
}


-(UITableViewCell *)configureTableViewCell:(UITableViewCell *)cell inTableView:(UITableView *)table forIndexPath:(NSIndexPath *)indexPath{
	cell.selectedBackgroundView = [self getCellSelectedBackgroundForTableView:table atIndexPath:indexPath];

	BOOL isOdd = [self shouldUsePrimaryColorShemeForIndexPath:indexPath forTableView:table];
	if(!isOdd){
		cell.detailTextLabel.textColor = [UIColor blackColor];
		cell.textLabel.highlightedTextColor = [UIColor applicationSecondaryColor];
		cell.textLabel.textColor = [UIColor applicationPrimaryColor];
		cell.textLabel.backgroundColor = [UIColor applicationSecondaryColor];
		cell.detailTextLabel.backgroundColor = [UIColor applicationSecondaryColor];
		cell.backgroundColor = [UIColor applicationSecondaryColor];
		cell.accessoryView = nil;
		cell.editingAccessoryView = nil;
		
		
		#if USE_TEXT_LABEL_SHADOWS
		cell.textLabel.shadowColor = [UIColor blueColor];
		cell.textLabel.shadowOffset = CGSizeMake(0, 1);//below
		#endif
		
	}
	else{
		cell.detailTextLabel.textColor = [UIColor whiteColor];
		cell.textLabel.textColor = [UIColor applicationSecondaryColor];
		cell.textLabel.highlightedTextColor = [UIColor applicationPrimaryColor];
		cell.textLabel.backgroundColor = [UIColor applicationPrimaryColor];
		cell.detailTextLabel.backgroundColor = [UIColor applicationPrimaryColor];
		cell.backgroundColor = [UIColor applicationPrimaryColor];
		if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
			UIImageView *whiteChevron = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WhiteChevron.png"]];
			whiteChevron.highlightedImage = [UIImage imageNamed:@"DarkChevron.png"];
			cell.accessoryView = whiteChevron;
		}
		else {
			cell.accessoryView = nil;
			cell.editingAccessoryView = nil;
		}

		
		
		#if USE_TEXT_LABEL_SHADOWS
		cell.textLabel.shadowColor = [UIColor blackColor];
		cell.textLabel.shadowOffset = CGSizeMake(0, -1);//above
		#endif
	}
	return cell;
}



#pragma mark App Wide Features

-(void)composeEmailTo:(NSString *)to withSubject:(NSString *)subject andBody:(NSString *)body{
	//
	if([MFMailComposeViewController canSendMail]){
		MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
		if(to!=nil){
			[mailView setToRecipients:[NSArray arrayWithObject:to]];
		}
		[mailView setSubject:subject];
		[mailView setMessageBody:body isHTML:YES];
		[navigationController.visibleViewController presentModalViewController:mailView animated:YES];
		mailView.mailComposeDelegate = (id<MFMailComposeViewControllerDelegate>)self;
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)err{
	[navigationController.visibleViewController dismissModalViewControllerAnimated:YES];
}

-(void)loadWebViewWithURL:(NSString *)theURL{
	if(theURL){
        //FIXME
        /*
		TTWebController *theWebView = [[TTWebController alloc] init];
		theWebView.navigationBarTintColor = [UIColor WVUBlueColor];
		NSURL *aURL = [NSURL URLWithString:theURL]; 
		[theWebView openURL:aURL];
		[self displayViewControllerFullScreen:theWebView];
		[theWebView release];
         */
	}
}



-(void)displayViewControllerFullScreen:(UIViewController *)viewController{
	[self.navigationController pushViewController:viewController animated:YES];
	MainScreen *rootView = [navigationController.viewControllers objectAtIndex:0];
	[rootView dismissForm];
}

-(void)callPhoneNumber:(NSString *)phoneNum{
	NSString *deviceModel = [UIDevice currentDevice].model;
	if ([deviceModel isEqualToString:@"iPhone"]) {
		while ([phoneNum characterAtIndex:0] == ' ') {
			phoneNum = [phoneNum substringFromIndex:1];
		}
		
		UIAlertView *err = [[UIAlertView alloc] initWithTitle:phoneNum message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call",nil];
		err.tag = 1;
		[err show];
	}
	else{
		NSString *message = [NSString stringWithFormat:@"The %@ does not support phone calls. You may call %@ from a phone.", deviceModel, phoneNum];
		UIAlertView *err = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[err show];
	}
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (alertView.tag == 1) {
		if ([@"Call" isEqualToString:[alertView buttonTitleAtIndex:buttonIndex]] ) {
			//turn a human readable number to a tel:XXXXXXXXXX format
			
			NSString *phoneNum = alertView.title;
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"(" withString:@""];
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@")" withString:@""];
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"ext." withString:@","];
			NSString *phoneNumWithPre = [NSString stringWithFormat:@"tel:%@", phoneNum];
			NSURL *phoneURL = [NSURL URLWithString:phoneNumWithPre];
			[[UIApplication sharedApplication] openURL:phoneURL];
		}
	}
}

-(void)serviceAttemptFailedForApp:(NSString *)application{
	NSString *message = [NSString stringWithFormat:@"%@ is not responding. This typically means the application is not installed.", application];
	UIAlertView *err = [[UIAlertView alloc] initWithTitle:application message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[err show];
}

-(void)callExternalApplication:(NSString *)application withURL:(NSString *)url{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	[self performSelector:@selector(serviceAttemptFailedForApp:) withObject:application afterDelay:0.5f]; 
}



#pragma mark Push Notifications (EasyAPNS)




-(void)easyAPNSinit{	
	#if !TARGET_IPHONE_SIMULATOR
	
	// Add registration for remote notifications
	[[UIApplication sharedApplication] 
	 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
	
	// Clear application badge when app launches
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	
	#endif
}






/**
 * Fetch and Format Device Token and Register Important Information to Remote Server
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	
	#if !TARGET_IPHONE_SIMULATOR
	
	// Get Bundle Info for Remote Registration (handy if you have more than one app)
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	// Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	
	// Set the defaults to disabled unless we find otherwise...
	NSString *pushBadge = @"disabled";
	NSString *pushAlert = @"disabled";
	NSString *pushSound = @"disabled";
	
	// Check what Registered Types are turned on. This is a bit tricky since if two are enabled, and one is off, it will return a number 2... not telling you which
	// one is actually disabled. So we are literally checking to see if rnTypes matches what is turned on, instead of by number. The "tricky" part is that the 
	// single notification types will only match if they are the ONLY one enabled.  Likewise, when we are checking for a pair of notifications, it will only be 
	// true if those two notifications are on.  This is why the code is written this way ;)
	if(rntypes == UIRemoteNotificationTypeBadge){
		pushBadge = @"enabled";
	}
	else if(rntypes == UIRemoteNotificationTypeAlert){
		pushAlert = @"enabled";
	}
	else if(rntypes == UIRemoteNotificationTypeSound){
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)){
		pushBadge = @"enabled";
		pushAlert = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)){
		pushBadge = @"enabled";
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
		pushAlert = @"enabled";
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
		pushBadge = @"enabled";
		pushAlert = @"enabled";
		pushSound = @"enabled";
	}
	
	
	// Get the users Device Model, Display Name, Unique ID, Token & Version Number
	UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid = dev.uniqueIdentifier;
    NSString *deviceName = dev.name;
	NSString *deviceModel = dev.model;
	NSString *deviceSystemVersion = dev.systemVersion;
	
	// Prepare the Device Token for Registration (remove spaces and < >)
	NSString *deviceToken = [[[[devToken description] 
							   stringByReplacingOccurrencesOfString:@"<"withString:@""] 
							  stringByReplacingOccurrencesOfString:@">" withString:@""] 
							 stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	// Build URL String for Registration
	// !!! CHANGE "www.mywebsite.com" TO YOUR WEBSITE. Leave out the http://
	// !!! SAMPLE: "secure.awesomeapp.com"
	NSString *host = @"easyapns.mobiexp.wvu.edu:8001";
	
	// !!! CHANGE "/apns.php?" TO THE PATH TO WHERE apns.php IS INSTALLED 
	// !!! ( MUST START WITH / AND END WITH ? ). 
	// !!! SAMPLE: "/path/to/apns.php?"
	NSString *urlString = [NSString stringWithFormat:@"/apns.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@&hours=%@", @"register", appName,appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound, [self getPRTQuietHours]];
	
	// Register the Device Data
	// !!! CHANGE "http" TO "https" IF YOU ARE USING HTTPS PROTOCOL
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSLog(@"Register URL: %@", url);
	
	NSString *response = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"Response: %@", response);
	NSLog(@"Return Data: %@", returnData);
	
	#endif
}

/**
 * Failed to Register for Remote Notifications
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"Error in registration. Error: %@", error);
}

/**
 * Remote Notification Received while application was open.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSLog(@"remote notification: %@",[userInfo description]);
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
	
	NSString *alert = [apsInfo objectForKey:@"alert"];
	NSLog(@"Received Push Alert: %@", alert);
	
	NSString *sound = [apsInfo objectForKey:@"sound"];
	NSLog(@"Received Push Sound: %@", sound);
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	
	NSString *badge = [apsInfo objectForKey:@"badge"];
	NSLog(@"Received Push Badge: %@", badge);
	application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
}

-(NSString *)getPRTQuietHours{
	return [[NSUserDefaults standardUserDefaults] valueForKey:@"PRTQuietHours"];
}

#pragma mark Memory





#pragma mark Version Upgrade

-(void)openAppStoreToNewVersion{
	NSString *str = @"itms-apps://ax.search.itunes.apple.com";
    str = [NSString stringWithFormat:@"%@/WebObjects/MZSearch.woa/wa/search?media=software&term=", str];
    str = [NSString stringWithFormat:@"%@iWVU", str];
	
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:str]];
}




-(void)cleanUpDocumentsFolder{
    //iCloud backs up the documents directory, and iWVU isn't currently designed to back up any data like that
    //the documents directory should always be empty
    
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"];
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    NSDirectoryEnumerator *dirEnum =
    [localFileManager enumeratorAtPath:docsDir];
    
    NSString *fileName;
    while (fileName = [dirEnum nextObject]) {
        NSString *filePath = [docsDir stringByAppendingPathComponent:fileName];
        NSError *err = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&err];
        NSLog(@"%@",err);
    }
}


@end

