//
//  RadioEngine.h
//  iWVU
//
//  Created by Jared Crawford on 6/23/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioStreamer.h"

@interface RadioEngine : UIResponder <AVAudioSessionDelegate>{
	AVAudioSession *session;
	AudioStreamer *streamer;
}

@property (nonatomic, retain) AVAudioSession *session;

-(void)beginStreaming;
-(void)stopStreaming;

@end
