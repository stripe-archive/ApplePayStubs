//
//  STPTestAddressStore.h
//  StripeExample
//
//  Created by Jack Flintermann on 9/30/14.
//  Copyright (c) 2014 Stripe. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "STPTestDataStore.h"
#import <AddressBook/AddressBook.h>

@interface STPTestAddressStore : NSObject<STPTestDataStore>

- (ABRecordRef)contactForSelectedItemObscure:(BOOL)obscure;
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
- (PKContact *)pkContactForSelectedItemObscure:(BOOL)obscure;
#endif

@end

