//
//  TTLauncherViewController.m
//  Three20
//
//  Created by Rodrigo Mazzilli on 9/25/09.


#import "Three20UI/TTLauncherViewController.h"

// UI
#import "Three20UI/TTView.h"
#import "Three20UI/UIViewAdditions.h"
#import "Three20UI/TTLauncherView.h"
#import "Three20UI/UINavigationControllerAdditions.h"

// UI (common)
#import "Three20UICommon/TTGlobalUICommon.h"
#import "Three20UICommon/UIViewControllerAdditions.h"

// Style
#import "Three20Style/TTDefaultStyleSheet.h"
#import "Three20Style/TTGlobalStyle.h"

// Network
#import "Three20Network/TTURLCache.h"
#import "Three20Network/TTGlobalNetwork.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

// Navigator
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"

// TODO : move these to global
#define	TT_LAUNCHER_SHOW_TRANSITION_DURATION 0.25
#define TT_LAUNCHER_HIDE_TRANSITION_DURATION 0.3
#define TTLAUNCHERVIEW_MAX_SIZE		CGSizeMake(320.0f, 416.0f)

@interface TTLauncherViewController (Private)
- (void)dismissChildAnimated:(BOOL)animated;
@end


@implementation TTLauncherViewController

@synthesize launcherNavigationController = _launcherNavigationController;
@synthesize launcherView = _launcherView;
@synthesize launcherNavigationControllerTopViewController = _launcherNavigationControllerTopViewController;

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
	TT_RELEASE_SAFELY(_overlayView);
	TT_RELEASE_SAFELY(_launcherView);
	TT_RELEASE_SAFELY(_launcherNavigationController);
    [super dealloc];
}

- (id)init {
	if (self = [super init]) {
		_launcherNavigationController = nil;
		_overlayView = nil;
		_launcherNavigationControllerTopViewController = nil;
	}
	return self;
}

#pragma mark -
#pragma mark UITableViewController

- (void)loadView {
	[super loadView];	
	_launcherView = [[TTLauncherView alloc] initWithFrame:self.view.bounds];
	_launcherView.backgroundColor = TTSTYLEVAR(launcherBackgroundColor);
	//self.view = _launcherView;
	[self.view addSubview:_headerView];
	[self.view addSubview:_launcherView];
	[self.view addSubview:_footerView];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[_launcherNavigationController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[_launcherNavigationController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[_launcherNavigationController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[_launcherNavigationController viewDidDisappear:animated];
}

- (CGAffineTransform)transformForOrientation {
	return TTRotateTransformForOrientation(TTInterfaceOrientation());
}

#pragma mark -
#pragma mark Overlay view

- (CGRect)rectForOverlayView {
	return [_launcherView frameWithKeyboardSubtracted:0];
}

- (void)addOverlayView {
	if (!_overlayView) {
		CGRect frame = [self rectForOverlayView];
		_overlayView = [[UIView alloc] initWithFrame:frame];
		_overlayView.backgroundColor = [UIColor blackColor];
		_overlayView.alpha = 0.0f;
		_overlayView.autoresizesSubviews = YES;
		_overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		[_launcherView addSubview:_overlayView];
	}
	self.view.frame = _overlayView.bounds;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)resetOverlayView {
	if (_overlayView && !_overlayView.subviews.count) {
		[_overlayView removeFromSuperview];
		TT_RELEASE_SAFELY(_overlayView);
	}
}

- (void)layoutOverlayView {
	if (_overlayView) {
		_overlayView.frame = [self rectForOverlayView];
	}
}

#pragma mark -
#pragma mark Animation delegates

- (void)showAnimationDidStop {
}

- (void)fadeAnimationDidStop {
	[self dismissChildAnimated:NO];
	TT_RELEASE_SAFELY(_overlayView);
}

- (void)fadeOut {
	UIView *viewToDismiss = [[_launcherNavigationController topViewController] view];

	viewToDismiss.transform = CGAffineTransformIdentity;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:TT_LAUNCHER_HIDE_TRANSITION_DURATION];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(fadeAnimationDidStop)];
	viewToDismiss.alpha = 0;		
	viewToDismiss.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
	_overlayView.alpha = 0.0f;
	[self resetOverlayView];
	[UIView commitAnimations];	
}


- (void)launchChild {

	UIView *viewToLaunch = [[_launcherNavigationController topViewController] view];
	viewToLaunch.transform = [self transformForOrientation];

	[self.superController.view addSubview:[_launcherNavigationController view]];
	
	viewToLaunch.frame = self.view.bounds;
	viewToLaunch.alpha = 0;		
	viewToLaunch.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
		
	// Add overlay view
	[self addOverlayView];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:TT_LAUNCHER_SHOW_TRANSITION_DURATION];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(showAnimationDidStop)];
	viewToLaunch.alpha = 1.0f;		
	viewToLaunch.transform = CGAffineTransformIdentity;
	_overlayView.alpha = 0.85f;
	[UIView commitAnimations];
}

- (void)addSubcontroller:(UIViewController*)controller animated:(BOOL)animated transition:(UIViewAnimationTransition)transition {
	if (!_launcherNavigationController) {
		_launcherNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
		_launcherNavigationController.superController = self;
		_launcherNavigationController.delegate = self;

		// Add default left-side button in navigation bar
		UIBarButtonItem *launcherBarButtonItem = [[UIBarButtonItem alloc] initWithImage:TTIMAGE(@"bundle://Three20.bundle/images/launcherButton.png") style:UIBarButtonItemStyleBordered target:self action:@selector(dismissChild)];
		[controller.navigationItem setLeftBarButtonItem:launcherBarButtonItem];
		[launcherBarButtonItem release];

		// Launch child
		[self launchChild];
		
	} else {
		[_launcherNavigationController addSubcontroller:controller animated:animated transition:transition];
		self.launcherNavigationControllerTopViewController = controller;
	}
}

- (void)dismissChild {
	[self dismissChildAnimated:YES];
}

- (void)dismissChildAnimated:(BOOL)animated {
	if (animated) {
		[self fadeOut];
	} else {
		[[_launcherNavigationController topViewController] viewWillDisappear:animated];
		UIView *viewToDismiss = [_launcherNavigationController view];
		[viewToDismiss removeFromSuperview];
		[[_launcherNavigationController topViewController] viewDidDisappear:animated];
		TT_RELEASE_SAFELY(_launcherNavigationController);
		[self.superController viewWillAppear:animated];
		[self.superController viewDidAppear:animated];
	}
	[[_launcherNavigationController topViewController] viewDidDisappear:animated];
}

#pragma mark -
#pragma mark UIViewController (TTCategory)

- (void)persistNavigationPath:(NSMutableArray*)path {
	if (_launcherNavigationController) {
		// We have controllers open inside the launcher controller, so persist it
		[_launcherNavigationController persistNavigationPath:path];
	}
}


#pragma mark -
#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController 
							willShowViewController:(UIViewController *)viewController 
							animated:(BOOL)animated {
	[_launcherNavigationControllerTopViewController viewWillDisappear:animated];
	[viewController viewWillAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController 
							didShowViewController:(UIViewController *)viewController 
							animated:(BOOL)animated {
	[_launcherNavigationControllerTopViewController viewDidDisappear:animated];
	[viewController viewDidAppear:animated];
	
	self.launcherNavigationControllerTopViewController = viewController;
}

#pragma mark -
#pragma mark Layout subviews

- (void)layoutSubviews {
	CGFloat headerHeight = 0.0f;
	CGFloat footerHeight = 0.0f;
	if (_headerView) {
		[_headerView setFrame:CGRectMake(0.0f, 0.0f, _headerView.frame.size.width,  _headerView.frame.size.height)];
		headerHeight = _headerView.frame.size.height;
	}

	if (_footerView) {
		footerHeight = _footerView.frame.size.height;
		[_footerView setFrame:CGRectMake(0.0f, self.view.bounds.size.height - footerHeight, _footerView.frame.size.width,  footerHeight)];
	}	
	[self.view addSubview:_headerView];
	[self.view addSubview:_footerView];
	[_launcherView setFrame:CGRectMake(0.0f, headerHeight, 320.0f, TTLAUNCHERVIEW_MAX_SIZE.height - footerHeight)];
}

#pragma mark -
#pragma mark Public

- (void)setHeaderView:(UIView *)headerView {
	TT_RELEASE_SAFELY(_headerView);
	_headerView = [headerView retain];
	[self layoutSubviews];
}

- (UIView *)headerView {
	return _headerView;
}

- (void)setFooterView:(UIView *)footerView {
	TT_RELEASE_SAFELY(_footerView);
	_footerView = [footerView retain];
	[self layoutSubviews];
}

- (UIView *)footerView {
	return _footerView;
}

@end
