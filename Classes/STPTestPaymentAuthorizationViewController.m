//
//  STPTestPaymentAuthorizationViewController.m
//  StripeExample
//
//  Created by Jack Flintermann on 9/30/14.
//  Copyright (c) 2014 Stripe. All rights reserved.
//

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

#import "STPTestPaymentAuthorizationViewController.h"
#import "STPTestPaymentSummaryViewController.h"

@interface STPTestPaymentAuthorizationViewController()<UIViewControllerTransitioningDelegate>
@property (nonatomic) PKPaymentRequest *paymentRequest;
@property (nonatomic) UIView *dimmingView2;
@end

@interface STPTestPaymentPresentationController : UIPresentationController
@end

@implementation STPTestPaymentAuthorizationViewController

- (instancetype)initWithPaymentRequest:(PKPaymentRequest *)paymentRequest {
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
		_paymentRequest = paymentRequest;
		self.transitioningDelegate = self;
		self.modalPresentationStyle = UIModalPresentationCustom;
	}
	return self;
}

- (void)viewWillLayoutSubviews {
	if (self.dimmingView2 == nil) {
		self.dimmingView2 = [[UIView alloc] initWithFrame:self.view.superview.frame];
		self.dimmingView2.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
		self.dimmingView2.layer.opacity = 0.0;
		
		CABasicAnimation *fadeInAnimation;
		fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
		fadeInAnimation.duration = 0.15;
		fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0];
		fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
		
		self.dimmingView2.layer.opacity = 1.0;
		
		[self.dimmingView2.layer addAnimation:fadeInAnimation forKey:@"opacity"];
		
		[self.view.superview insertSubview:self.dimmingView2 atIndex:0];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	STPTestPaymentSummaryViewController *summary = [[STPTestPaymentSummaryViewController alloc] initWithPaymentRequest:self.paymentRequest];
	summary.delegate = self.delegate;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:summary];
	[navController.navigationBar setBackgroundImage:[UIImage new]
									  forBarMetrics:UIBarMetricsDefault];
	navController.navigationBar.shadowImage = [UIImage new];
	navController.navigationBar.translucent = YES;
	
	[self addChildViewController:navController];
	navController.view.frame = self.view.bounds;
	[self.view addSubview:navController.view];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
	return [[STPTestPaymentPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

@end

@implementation STPTestPaymentPresentationController
- (CGRect)frameOfPresentedViewInContainerView {
	CGRect rect = [super frameOfPresentedViewInContainerView];
	rect.origin.y += 150;
	rect.size.height -= 150;
	return rect;
}
@end

#endif