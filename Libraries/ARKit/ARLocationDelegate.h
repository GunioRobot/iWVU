//
//  ARLocationDelegate.h
//  ARKitDemo
//
//  Created by Jared Crawford on 2/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARGeoCoordinate.h"


@protocol ARLocationDelegate

//returns an array of ARGeoCoordinates
-(NSMutableArray *)getLocations;

@end

