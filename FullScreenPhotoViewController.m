//
//  FullScreenPhotoViewController.m
//  iWVU
//
//  Created by Jared Crawford on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FullScreenPhotoViewController.h"


@implementation FullScreenPhotoViewController

@synthesize flowView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	flowView.dataSource = self;
	flowView.viewDelegate = self;
	
	theDefaultImage = [[UIImage imageNamed:@"FlyingWVDefaultBig.png"] retain];
	CGRect tempRect = CGRectMake(0, 0, OPENFLOW_IMAGE_SIZE, OPENFLOW_IMAGE_SIZE);
	[theDefaultImage drawInRect:tempRect];
	
	[flowView setNumberOfImages:12];
	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		return YES;
	}
	else if(interfaceOrientation == UIInterfaceOrientationLandscapeRight){
		return YES;
	}
    return NO;
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


- (void)dealloc {
    [super dealloc];
}





//OpenFlow Delegate

- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index{
	
}
- (void)openFlowView:(AFOpenFlowView *)openFlowView didTap:(int)index{
	
}
- (void)openFlowView:(AFOpenFlowView *)openFlowView didDoubleTap:(int)index{
	
}
- (void)openFlowViewAnimationDidBegin:(AFOpenFlowView *)openFlowView{
	
}
- (void)openFlowViewAnimationDidEnd:(AFOpenFlowView *)openFlowView{
	
}




//OpenFlow DataSource

- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index{
	[openFlowView setImage:[self defaultImage] forIndex:index];
}
- (UIImage *)defaultImage{
	return theDefaultImage;
}




@end
