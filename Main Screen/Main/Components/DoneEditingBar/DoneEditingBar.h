//
//  DoneEditingBar.h
//  iWVU
//
//  Created by Jared Crawford on 1/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

@protocol DoneEditingBarDelegate;

@interface DoneEditingBar : TTActivityLabel {

	id<DoneEditingBarDelegate> delegate;
	
}

@property (nonatomic,assign) id<DoneEditingBarDelegate> delegate;

+(DoneEditingBar *)createBar;
-(void)setStyle;

@end


@protocol DoneEditingBarDelegate

-(void)doneEditingBarHasFinished:(DoneEditingBar *)bar;
@end