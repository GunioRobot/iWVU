//
//  JCDismissableDownloadIndicator.h
//  iWVU
//
//  Created by Jared Crawford on 10/23/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TapkuLibrary/TapkuLibrary.h>


@protocol JCDismissableDownloadIndicatorDelegate;

@interface JCDismissableDownloadIndicator : TKProgressAlertView {
	UIButton *_dismissalButton;
	id<JCDismissableDownloadIndicatorDelegate> __unsafe_unretained delegate;
	BOOL displaysDownloadStatus;
}
@property (weak, nonatomic, readonly) UIButton *dismissalButton;
@property (nonatomic, unsafe_unretained) id<JCDismissableDownloadIndicatorDelegate> delegate;

- (id) initWithProgressTitleButNoProgressBar:(NSString*)txt;

@end


@protocol JCDismissableDownloadIndicatorDelegate


-(void)downloadIndicatorDismissed:(JCDismissableDownloadIndicator *)indicator;

@end