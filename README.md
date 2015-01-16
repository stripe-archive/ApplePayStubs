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
 This usually includes a `PKPayment` that contains encrypted credit card data that you'd pass off to your payment processor (such as Stripe). To approximate this functionality, we attach a credit card number to the `PKPayment` under the `stp_testCardNumber` property. If you're using Stripe to handle this token, you can use our existing card APIs to turn this into a token:

```objc
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    void(^tokenBlock)(STPToken *token, NSError *error) = ^void(STPToken *token, NSError *error) {
        if (error) {
            completion(PKPaymentAuthorizationStatusFailure);
        }
        else {
            [self createBackendChargeWithToken:token completion:completion];
        }
    };
#if DEBUG
    STPCard *card = [STPCard new];
    card.number = payment.stp_testCardNumber;
    card.expMonth = 12;
    card.expYear = 2020;
    card.cvc = @"123";
    [Stripe createTokenWithCard:card completion:tokenBlock];
#else
    [Stripe createTokenWithPayment:payment
                    operationQueue:[NSOperationQueue mainQueue]
                        completion:tokenBlock];

}

```

(Note for the above example: Stripe tokens created from Apple Pay work interchangably with those created using manually-collected credit card details).

Example App / Learn More
---

If you'd like to see more examples of how to use this, we use ApplePayStubs in the [example app](https://github.com/stripe/stripe-ios/tree/master/Example) for our [main iOS library](https://github.com/stripe/stripe-ios).

If you'd like to learn more about accepting payments on iOS with Stripe in general, read our [iOS tutorial](https://stripe.com/docs/mobile/ios).
