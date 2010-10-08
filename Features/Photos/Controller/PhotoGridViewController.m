    //
//  PhotoGridViewController.m
//  iWVU
//
//  Created by Jared Crawford on 10/8/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "PhotoGridViewController.h"
#import "PhotoDataSource.h"


@implementation PhotoGridViewController

- (void)viewDidLoad {
    
	NSString *url =  @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20xml%20where%20url%3D%27http%3A%2F%2Fphotoarchive.sitespace.wvu.edu%2Fr%2Fslideshow%2Fordered%2F3628.xml%27%20limit%201&format=json";
	
	PhotoDataSource *dataSource = [[PhotoDataSource alloc] initWithTitle:@"WVU Photos" andURL:url];
	
	self.photoSource = dataSource;
	self.delegate = dataSource;
	
	[super viewDidLoad];
	
	
}


- (void)dealloc {
	[self.photoSource release];
    [super dealloc];
}


@end
