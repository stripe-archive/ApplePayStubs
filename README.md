ApplePayStubs
===

What is this?
---

ApplePay is awesome. However, since it isn't available in every country yet, and only then on the newest iOS devices, we want to make it easier for developers to plan and test their Apple Pay integrations.

We've created a replacement component for `PKPaymentAuthorizationViewController` (the primary class involved in ApplePay transactions) for businesses interested in working with ApplePay called `STPTestPaymentAuthorizationViewController`. These classes appear visually similar and behave almost identically. The primary difference is that `STPTestPaymentAuthorizationViewController` yields test credit cards and addresses instead of accessing actual information stored on a user's iPhone. You can use it to build and test all of your UI and application logic around ApplePay, and switch it out for the real thing once you have access to a proper testing device.

Please note that this is for **testing and development purposes only**.

Dependencies
---
- Xcode 6+
- iOS 8+

ApplePayStubs also depends on the `PassKit` framework.

Installation
---
Use Cocoapods or manually add the files to your repository.

Usage
---

You create and use instances of `STPTestPaymentAuthorizationViewController` exactly the same way as with 
`PKPaymentAuthorizationViewController`.

```objc
// ViewController.m
- (void)checkoutButtonTapped {
    PKPaymentRequest *request = ...;
    UIViewController *controller;
#if DEBUG
    controller = [[STPTestPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    controller.delegate = self;
#else
    controller = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    controller.delegate = self;

    [self presentViewController:controller];
}
```

`STPTestPaymentAuthorizationViewController` will trigger the same `PKPaymentAuthorizationViewControllerDelegate` callbacks at the appropriate time on its delegate.

```objc
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                  didSelectShippingAddress:(ABRecordRef)address
                                completion:(void (^)(PKPaymentAuthorizationStatus status, NSArray *shippingMethods, NSArray *summaryItems))completion {
    [self fetchShippingCostsForAddress:address completion:^(NSArray *shippingMethods, NSError *error) {
        if (error) {
            completion(PKPaymentAuthorizationStatusFailure, nil, nil);
            return;
        }
        completion(PKPaymentAuthorizationStatusSuccess, shippingMethods, [self summaryItemsForShippingMethod:shippingMethods.firstObject]);
    }];
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                   didSelectShippingMethod:(PKShippingMethod *)shippingMethod
                                completion:(void (^)(PKPaymentAuthorizationStatus, NSArray *summaryItems))completion {
    completion(PKPaymentAuthorizationStatusSuccess, [self summaryItemsForShippingMethod:shippingMethod]);
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}
```

When the user finishes selecting a card, as usual `STPTestPaymentAuthorizationViewController` will call `paymentAuthorizationViewController:didAuthorizePayment:completion` on its delegate.
 This delegate method includes a `PKPayment` object, which itself has an instance of `PKPaymentToken` that contains encrypted credit card data that you'd pass off to your payment processor (such as Stripe). While the `PKPayment` and `PKPaymentToken` returned by ApplePayStubs have stubbed (and invalid) versions of this data, the Stripe API will be able to recognize them in testmode. As such, you shouldn't have to modify your existing `PKPaymentAuthorizationViewControllerDelegate` methods:

```objc
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
                                
    [[STPAPIClient sharedClient] createTokenWithPayment:payment
        completion:^(STPToken *token, NSError *error) {
            [self createBackendChargeWithToken:token
                                    completion:^(STPBackendChargeResult status, NSError *error) {
                if (status == STPBackendChargeResultSuccess) {
                    completion(PKPaymentAuthorizationStatusSuccess);
                } else {
                    completion(PKPaymentAuthorizationStatusFailure);
                }
        }];
    }];
}
```

(Note: Stripe tokens created from Apple Pay work interchangeably with those created using manually-collected credit card details).

If you're not using Stripe, you can find the selected card information on the `PKPayment`'s `PKPaymentToken` in the `transactionIdentifier` field, in the format `"ApplePayStubs~{card_number}~{amount_in_cents}~{currency}~{uuid}"`.

Example App / Learn More
---

If you'd like to see more examples of how to use this, we use ApplePayStubs in the [example app](https://github.com/stripe/stripe-ios/tree/master/Example) for our [main iOS library](https://github.com/stripe/stripe-ios).

If you'd like to learn more about accepting payments on iOS with Stripe in general, read our [iOS tutorial](https://stripe.com/docs/mobile/ios).
