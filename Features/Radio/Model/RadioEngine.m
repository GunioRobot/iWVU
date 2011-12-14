//
//  RadioEngine.m
//  iWVU
//
//  Created by Jared Crawford on 6/23/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "RadioEngine.h"
#import "Reachability.h"



#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>

@implementation RadioEngine

@synthesize session;

-(void)createSession{
	session = [AVAudioSession sharedInstance];
	NSError *sessionError;
	[session setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
	session.delegate = self;
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
}


-(NSURL *)determineStreamURL{
	NSString *path = @"157.182.129.241";
	
	
	[[Reachability sharedReachability] setHostName:path];
	
	NetworkStatus internetStatus = [[Reachability sharedReachability] remoteHostStatus];
	
	if ((internetStatus != ReachableViaWiFiNetwork) && (internetStatus != ReachableViaCarrierDataNetwork))
	{
		UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"An internet connection is required to stream U92." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[myAlert show];
		path = @"";
	}
	else if(internetStatus == ReachableViaWiFiNetwork){
		path = @"http://157.182.129.241:554/u92Live-256k";
	}
	else{
		path = @"http://157.182.129.241:554/u92Live-32k-mono";
	}
	
	
	return [NSURL URLWithString:path];
}



-(void)beginStreaming{
	if (!session) {
		[self createSession];
	}
	if(!streamer){
		NSURL *streamURL = [self determineStreamURL];
		streamer = [[AudioStreamer alloc] initWithURL:streamURL];
	}
	[streamer start];
}

-(void)stopStreaming{
	if (streamer) {
		[streamer stop];
	}
	streamer = nil;
	session = nil;
}

-(BOOL)canBecomeFirstResponder{
	return YES;
}


- (void)beginInterruption{
	//update user interface
	//audio has already stopped
}

- (void)endInterruptionWithFlags:(NSUInteger)flags{
	if (flags & AVAudioSessionInterruptionFlags_ShouldResume) {
		[self beginStreaming];
	}
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
	switch (event.type) {
		case UIEventSubtypeRemoteControlTogglePlayPause:
			if ((!streamer)||(![streamer isPlaying])) {
				[self beginStreaming];
			}
			else {
				[self stopStreaming];
			}
			break;
	}
}







-(void)releaseAlert:(UIAlertView *)alert{
	[alert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)displayNetworkSearchPopup{
	UIAlertView *loading = [[UIAlertView alloc] initWithTitle:nil message:@"Determining optimal network settings..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
	UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityView.frame = CGRectMake(139.0f-18.0f, 80.0f, 37.0f, 37.0f);
	[loading addSubview:activityView];
	[activityView startAnimating];
	[loading show];
	[self performSelector:@selector(releaseAlert:) withObject:loading afterDelay:5];
}

@end
