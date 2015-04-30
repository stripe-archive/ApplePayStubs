//
//  STPTestCardStore.m
//  StripeExample
//
//  Created by Jack Flintermann on 9/30/14.
//  Copyright (c) 2014 Stripe. All rights reserved.
//



#import "STPTestCardStore.h"

NSString *const STPSuccessfulChargeCardNumber = @"4242424242424242";
NSString *const STPFailingChargeCardNumber =    @"4000000000000002";

@interface STPTestCardStore ()
@property (nonatomic) NSArray *allItems;
@end

@implementation STPTestCardStore

@synthesize selectedItem;

+ (NSDictionary *)defaultCard {
    NSMutableDictionary *card = [NSMutableDictionary new];
    card[@"name"] = @"Stripe Test Card";
    card[@"number"] = STPSuccessfulChargeCardNumber;
    card[@"last4"] = [STPSuccessfulChargeCardNumber substringFromIndex:STPSuccessfulChargeCardNumber.length-4];
    card[@"expMonth"] = @12;
    card[@"expYear"] = @2030;
    card[@"cvc"] = @"123";
    return [card copy];
}

+ (NSDictionary *)defaultFailingCard {
    NSMutableDictionary *card = [NSMutableDictionary new];
    card[@"name"] = @"Stripe Test Card";
    card[@"number"] = STPFailingChargeCardNumber;
    card[@"last4"] = [STPFailingChargeCardNumber substringFromIndex:STPSuccessfulChargeCardNumber.length-4];
    card[@"expMonth"] = @12;
    card[@"expYear"] = @2030;
    card[@"cvc"] = @"123";
    return [card copy];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.allItems = @[[self.class defaultCard], [self.class defaultFailingCard]];
        self.selectedItem = self.allItems[0];
    }
    return self;
}

- (NSArray *)descriptionsForItem:(id)item {
    NSDictionary *card = (NSDictionary *)item;
    NSString *number = card[@"number"];
    NSString *suffix = [number substringFromIndex:MAX((NSInteger)[number length] - 4, 0)];
    return @[card[@"name"], [NSString stringWithFormat:@"**** **** **** %@", suffix]];
}

@end

