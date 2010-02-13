//
//  ARKit.m
//  ARKitDemo
//
//  Created by Jared Crawford on 2/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ARKit.h"


@implementation ARKit

+(BOOL)deviceSupportsAR{
	
	//Detect camera, if not there, return NO
	if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
		return NO;
	}
	
	//Detect compass, if not there, return NO
	CLLocationManager *locMan = [[CLLocationManager alloc] init];
	if(!locMan.headingAvailable){
		[locMan release];
		return NO;
	}
	[locMan release];
	
	//cannot detect presence of GPS
	//I could look at location accuracy, but the GPS takes too long to
	//initialize to be effective for a quick check
	//I'll assume if you made it this far, it's there
	
	return YES;
}
@end
