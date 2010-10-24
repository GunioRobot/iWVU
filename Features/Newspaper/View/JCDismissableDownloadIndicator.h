//
//  JCDismissableDownloadIndicator.h
//  iWVU
//
//  Created by Jared Crawford on 10/23/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TapkuLibrary/TapkuLibrary.h>
#import <Three20/Three20.h>

@protocol JCDismissableDownloadIndicatorDelegate;

@interface JCDismissableDownloadIndicator : TKProgressAlertView {
	TTButton *_dismissalButton;
	id<JCDismissableDownloadIndicatorDelegate> delegate;
	BOOL displaysDownloadStatus;
}
@property (nonatomic, readonly) TTButton *dismissalButton;
@property (nonatomic, assign) id<JCDismissableDownloadIndicatorDelegate> delegate;

- (id) initWithProgressTitleButNoProgressBar:(NSString*)txt;

@end


@protocol JCDismissableDownloadIndicatorDelegate


-(void)downloadIndicatorDismissed:(JCDismissableDownloadIndicator *)indicator;

@end