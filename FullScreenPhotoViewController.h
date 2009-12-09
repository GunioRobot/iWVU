//
//  FullScreenPhotoViewController.h
//  iWVU
//
//  Created by Jared Crawford on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFOpenFlowView.h"

#define OPENFLOW_IMAGE_SIZE 256

@interface FullScreenPhotoViewController : UIViewController <AFOpenFlowViewDelegate, AFOpenFlowViewDataSource>{

	IBOutlet AFOpenFlowView *flowView;
	
	UIImage *theDefaultImage;
	
}

@property (nonatomic, retain) AFOpenFlowView *flowView;




@end
