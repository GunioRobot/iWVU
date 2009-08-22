//
//  BuildingLocationController.m
//  iWVU
//
//  Created by Jared Crawford on 6/13/09.
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

#import "BuildingLocationController.h"
#import "POI.h"


@implementation BuildingLocationController

@synthesize buildingName;



 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	theMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 372)];
	theMapView.mapType = MKMapTypeSatellite;
	theMapView.delegate = self;
	
	[self.view addSubview:theMapView];
	[self.view sendSubviewToBack:theMapView];
	
	//////////////////////////
	
	
	if(buildingName == nil){
		self.buildingName = @"Mountainlair";
	}
	
	pins = [[NSMutableArray alloc] initWithCapacity:1]; 
	
	//////////////////////////
	
	NSString *path = [[NSBundle mainBundle] bundlePath];

	NSDictionary *latDict = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"BuildingsLat.plist"]];
	NSDictionary *longDict = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"BuildingsLong.plist"]];
	
	CLLocationCoordinate2D viewCenter;
	
	MKCoordinateSpan viewSpan;
	
	
	
	
	if([@"All Buildings" isEqualToString:buildingName]){
		//
		double longCo, latCo;
		
		for(NSString *build in latDict){
			latCo = [[latDict objectForKey:build] doubleValue];
			longCo = [[longDict objectForKey:build] doubleValue];
			if(latCo != 0){
				viewCenter.latitude = latCo;
				viewCenter.longitude = longCo;
				POI *poi = [[POI alloc] initWithCoords:viewCenter];
				poi.title = build;
				[theMapView addAnnotation:poi];
				[pins addObject:poi];
				[poi release];
			}
		}
		
		
		viewCenter.latitude = 39.646015;
		viewCenter.longitude = -79.961929;
		
		double kms = 5;
		
		viewSpan.latitudeDelta = kms/111.0; //1km
		viewSpan.longitudeDelta = kms/111.0; // ~<1km
		
		
		
		
		
		
	}
	else if([@"All Stations" isEqualToString:buildingName]){
		//
		
		
		double longCo, latCo;
		
		
		NSArray *PRTstations = [[NSArray alloc] initWithObjects:
								@"Walnut PRT Station",
								@"Downtown PRT Station",
								@"Engineering PRT Station",
								@"Towers PRT Station",
								@"Medical PRT Station",
								nil];
		
		
		
		for(NSString *build in PRTstations){
			latCo = [[latDict objectForKey:build] doubleValue];
			longCo = [[longDict objectForKey:build] doubleValue];
			if(latCo != 0){
				viewCenter.latitude = latCo;
				viewCenter.longitude = longCo;
				POI *poi = [[POI alloc] initWithCoords:viewCenter];
				poi.title = build;
				[theMapView addAnnotation:poi];
				[pins addObject:poi];
				[poi release];
			}
		}
		[PRTstations release];
		
		viewCenter.latitude = 39.646015;
		viewCenter.longitude = -79.961929;
		
		double kms = 5;
		
		viewSpan.latitudeDelta = kms/111.0; //1km
		viewSpan.longitudeDelta = kms/111.0; // ~<1km
		
	}
	else{
		
		viewSpan.latitudeDelta = 1/111.0; //1km
		viewSpan.longitudeDelta = 1/111.0; // ~<1km
		
		
		
		viewCenter.latitude = [[latDict objectForKey:buildingName] doubleValue];
		viewCenter.longitude = [[longDict objectForKey:buildingName] doubleValue];
		
		
		
		
		if(viewCenter.latitude == 0){
			NSString *errMessage = [buildingName stringByAppendingString:@" is not available. If you know the location of this building, please contact the developer."];
			UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Unavailable" message:errMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[err show];
			[err release];
		}
		
		
		
		POI *poi = [[POI alloc] initWithCoords:viewCenter];
		poi.title = buildingName;
		[pins addObject:poi];
		[theMapView addAnnotation:poi];
		[poi release];
		
		
	}
	
	MKCoordinateRegion viewRegion;
	viewRegion.center = viewCenter;
	viewRegion.span = viewSpan;
	
	theMapView.region = viewRegion;
	
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
	/*
	if([theMapView respondsToSelector:@selector(_suspendSearchResultsProcessingAndPinDropAnimations)]){
		[theMapView _suspendSearchResultsProcessingAndPinDropAnimations];
	}
	if([theMapView respondsToSelector:@selector(stopEffects)]){
		[theMapView stopEffects];
	}
	 */
	if([theMapView respondsToSelector:@selector(_stopTileLoading)]){
		[theMapView _stopTileLoading];
	}
	 
	[theMapView removeAnnotations:pins];
	[pins release];
	[theMapView release];
	self.buildingName = nil;
    [super dealloc];
}




-(IBAction)changeViewType:(id)sender{
	//
	UISegmentedControl *choice = (UISegmentedControl *)sender;
	NSString *pref = [choice titleForSegmentAtIndex:choice.selectedSegmentIndex];
	if([@"Satelite" isEqualToString:pref]){
		theMapView.mapType = MKMapTypeSatellite;
	}
	else if([@"Map" isEqualToString:pref]){
		theMapView.mapType = MKMapTypeStandard;
	}
	else if([@"Hybrid" isEqualToString:pref]){
		theMapView.mapType = MKMapTypeHybrid;
	}
}


-(IBAction)enableUserLocation:(id)sender{
	//
	if(theMapView.showsUserLocation == YES){
		theMapView.showsUserLocation = NO;
	}
	else{
		theMapView.showsUserLocation = YES;
	}
}



- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	if(annotation != mapView.userLocation){
		MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
		annotationView.animatesDrop = YES;
		annotationView.canShowCallout = YES;
		return annotationView;
	}
	return nil;
}



@end
