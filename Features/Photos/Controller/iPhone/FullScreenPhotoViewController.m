//
//  FullScreenPhotoViewController.m
//  iWVU
//
//  Created by Jared Crawford on 12/4/09.
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
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	returnButton.frame = CGRectMake(10, 10, returnButton.frame.size.width, returnButton.frame.size.height);
	flowView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

	
	theDefaultImage = [UIImage imageNamed:@"FlyingWVDefaultBig.png"];
	theDefaultImage = [self resizeImage:theDefaultImage withWidth:OPENFLOW_IMAGE_SIZE andHeight:OPENFLOW_IMAGE_SIZE];
	[theDefaultImage retain];
	[flowView setNumberOfImages:12];

	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		return NO;
	}
	
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[UIView beginAnimations:@"fadeOutCoverFlow" context:[[NSNumber numberWithDouble:duration] retain]];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(fadeOutCoverFlowFinished:finished:context:)];
	[UIView setAnimationDuration:duration];
	returnButton.frame = CGRectMake(10, 10, returnButton.frame.size.width, returnButton.frame.size.height);
	flowView.alpha = 0;
	[UIView commitAnimations];
	 
	
	
	[UIApplication sharedApplication].statusBarOrientation = toInterfaceOrientation;
}



- (void)fadeOutCoverFlowFinished:(NSString *)animationID finished:(NSNumber *)finished context:(NSNumber *)duration{
	[flowView removeFromSuperview];
	[flowView release];
	flowView = [[AFOpenFlowView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	flowView.dataSource = self;
	flowView.viewDelegate = self;
	[flowView setNumberOfImages:12];
	[self.view addSubview:flowView];
	[self.view sendSubviewToBack:flowView];
	flowView.alpha = 0;
	
	[UIView beginAnimations:@"fadeInCoverFlow" context:nil];
	[UIView setAnimationDuration:[duration doubleValue]];
	flowView.alpha = 1;
	[UIView commitAnimations];
	[duration release];
	 
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


-(UIImage *)resizeImage:(UIImage *)image withWidth:(NSInteger)width andHeight:(NSInteger)height {
	
	CGImageRef imageRef = [image CGImage];
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
	
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
	
	CGContextRef bitmap;
	
	if (image.imageOrientation == UIImageOrientationUp || image.imageOrientation == UIImageOrientationDown) {
		bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
		
	} else {
		bitmap = CGBitmapContextCreate(NULL, height, width, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
		
	}
	
	if (image.imageOrientation == UIImageOrientationLeft) {
		NSLog(@"image orientation left");
		CGContextRotateCTM (bitmap, radians(90));
		CGContextTranslateCTM (bitmap, 0, -height);
		
	} else if (image.imageOrientation == UIImageOrientationRight) {
		NSLog(@"image orientation right");
		CGContextRotateCTM (bitmap, radians(-90));
		CGContextTranslateCTM (bitmap, -width, 0);
		
	} else if (image.imageOrientation == UIImageOrientationUp) {
		NSLog(@"image orientation up");	
		
	} else if (image.imageOrientation == UIImageOrientationDown) {
		NSLog(@"image orientation down");	
		CGContextTranslateCTM (bitmap, width,height);
		CGContextRotateCTM (bitmap, radians(-180.));
		
	}
	
	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage *result = [UIImage imageWithCGImage:ref];
	
	CGColorSpaceRelease(colorSpaceInfo);
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return result;	
}


-(IBAction)returnButtonPressed{
	[self.navigationController popViewControllerAnimated:YES];
	[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
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
