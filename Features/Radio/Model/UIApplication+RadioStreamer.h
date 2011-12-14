//
//  UIApplication+RadioStreamer.h
//  iWVU
//
//  Created by Jared Crawford on 6/24/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioStreamer.h"

//This is an abstract superclass to the U92ViewController
//because the remote controls are used, these methods need to be in a ViewController
//but they should be a model component so they can be used on both iPhone and iPad
//This is a compromise.

//@interface RadioViewController : UIViewController <AVAudioSessionDelegate>{
@interface UIApplication (RadioStreamer)

-(void)beginStreaming;
-(void)stopStreaming;
-(void)playPauseButtonPressed;
-(BOOL)isStreamingRadio;

@end
