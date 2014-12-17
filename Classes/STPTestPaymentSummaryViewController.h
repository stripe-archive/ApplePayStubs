//
//  STPTestPaymentSummaryViewController.h
//  StripeExample
//
//  Created by Jack Flintermann on 9/8/14.
//  Copyright (c) 2014 Stripe. All rights reserved.
//

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>

@interface STPTestPaymentSummaryViewController : UIViewController

- (instancetype)initWithPaymentRequest:(PKPaymentRequest *)paymentRequest;
@property(nonatomic, assign)id<PKPaymentAuthorizationViewControllerDelegate>delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *knockoutView;

@end

#endif