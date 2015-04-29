//
//  STPTestCardStore.h
//  StripeExample
//
//  Created by Jack Flintermann on 9/30/14.
//  Copyright (c) 2014 Stripe. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "STPTestDataStore.h"

extern NSString * const STPSuccessfulChargeCardNumber;
extern NSString * const STPFailingChargeCardNumber;

@interface STPTestCardStore : NSObject <STPTestDataStore>
@end

