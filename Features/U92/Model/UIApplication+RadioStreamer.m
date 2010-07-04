//
//  UIApplication+RadioStreamer.m
//  iWVU
//
//  Created by Jared Crawford on 6/24/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "UIApplication+RadioStreamer.h"


#import "Reachability.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>


@implementation UIApplication (RadioStreamer)


-(void)configureSession{
	AVAudioSession *session = [AVAudioSession sharedInstance];
	NSError *sessionError;
	[session setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
	session.delegate = (id <AVAudioSessionDelegate>)self;
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	BOOL firstResponder = [self becomeFirstResponder];
	if(firstResponder == NO){
		NSLog(@"Failed to take first responder");
	}
}


-(NSURL *)determineStreamURL{
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
		path = @"http://157.182.129.241:554/u92Live-256k";
	}
	else{
		path = @"http://157.182.129.241:554/u92Live-32k-mono";
	}
	
	
	return [NSURL URLWithString:path];
}



-(void)beginStreaming{
	[self configureSession];
	iWVUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	if(!appDelegate.streamer){
		NSURL *streamURL = [self determineStreamURL];
		appDelegate.streamer = [[AudioStreamer alloc] initWithURL:streamURL];
	}
	[appDelegate.streamer start];
}

-(void)stopStreaming{
	iWVUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	[appDelegate.streamer stop];
	appDelegate.streamer = nil;
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
	switch (event.subtype) {
		case UIEventSubtypeRemoteControlTogglePlayPause:
		case  UIEventSubtypeRemoteControlPause:
		case UIEventSubtypeRemoteControlPlay:   
			[self playPauseButtonPressed];
			break;
	}
}

-(void)playPauseButtonPressed{
	if ([self isStreamingRadio]) {
		[self stopStreaming];
	}
	else {
		[self beginStreaming];
	}
}

-(BOOL)isStreamingRadio{
	iWVUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	if (appDelegate.streamer) {
		return YES;
	}
	return NO;
}


@end

