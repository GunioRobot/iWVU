//
//  PhotoGridViewController.h
//  iWVU
//
//  Created by Jared Crawford on 10/8/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "PhotoDataSource.h"

@interface PhotoGridViewController : TTThumbsViewController {
	PhotoDataSource *thePhotoSource;
}

@end
