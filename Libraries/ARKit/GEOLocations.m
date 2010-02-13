//
//  GEOLocations.m
//  iPhoneAugmentedRealityLib
//
//  Created by Niels W Hansen on 12/19/09.
//  Copyright 2009 Zac White. All rights reserved.
//

#import "GEOLocations.h"
#import "ARGeoCoordinate.h"
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@implementation GEOLocations

- (id)initWithDelegate:(id<ARLocationDelegate>) aDelegate{
	self.delegate = aDelegate;

	return self;
}

-(NSMutableArray*) getLocations 
{
	return [delegate getLocations];
}

- (void)dealloc {
	
    [locationArray release];
    [super dealloc];
}


@synthesize locationArray;
@synthesize delegate;
@end
