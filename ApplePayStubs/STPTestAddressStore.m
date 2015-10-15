//
//  STPTestAddressStore.m
//  StripeExample
//
//  Created by Jack Flintermann on 9/30/14.
//  Copyright (c) 2014 Stripe. All rights reserved.
//

@import PassKit;
#import "STPTestAddressStore.h"

@interface STPTestAddressStore ()
@property (nonatomic) NSArray *allItems;
@end

@implementation STPTestAddressStore

@synthesize selectedItem;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.allItems = @[
            @{
                @"name": @"Apple HQ",
                @"line1": @"1 Infinite Loop",
                @"line2": @"",
                @"city": @"Cupertino",
                @"state": @"CA",
                @"zip": @"95014",
                @"country": @"United States",
                @"phone": @"888 555-1212",
            },
            @{
                @"name": @"The White House",
                @"line1": @"1600 Pennsylvania Ave NW",
                @"line2": @"",
                @"city": @"Washington",
                @"state": @"DC",
                @"zip": @"20500",
                @"country": @"United States",
                @"phone": @"888 867-5309",
            },
            @{
                @"name": @"Buckingham Palace",
                @"line1": @"SW1A 1AA",
                @"line2": @"",
                @"city": @"London",
                @"state": @"",
                @"zip": @"",
                @"country": @"United Kingdom",
                @"phone": @"07 987 654 321",
            },
        ];
        self.selectedItem = self.allItems[0];
    }
    return self;
}

- (NSArray *)descriptionsForItem:(id)item {
    return @[item[@"name"], item[@"line1"]];
}

- (ABRecordRef)contactForSelectedItemObscure:(BOOL)obscure {
    id item = self.selectedItem;
    ABRecordRef record = ABPersonCreate();

    // address
    ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABDictionaryPropertyType);
    CFStringRef keys[6];
    CFStringRef values[6];
    CFIndex numValues = 0;

    if (!obscure) {
        keys[numValues] = kABPersonAddressStreetKey;
        values[numValues++] = CFBridgingRetain(item[@"line1"]);
    }
    keys[numValues] = kABPersonAddressCityKey;
    values[numValues++] = CFBridgingRetain(item[@"city"]);
    keys[numValues] = kABPersonAddressStateKey;
    values[numValues++] = CFBridgingRetain(item[@"state"]);
    keys[numValues] = kABPersonAddressZIPKey;
    values[numValues++] = CFBridgingRetain(item[@"zip"]);
    keys[numValues] = kABPersonAddressCountryKey;
    values[numValues++] = CFBridgingRetain(item[@"country"]);
    keys[numValues] = kABPersonAddressCountryCodeKey;
    values[numValues++] = CFBridgingRetain(item[@"countryCode"]);

    
    CFDictionaryRef aDict = CFDictionaryCreate(
        kCFAllocatorDefault, (const void **)keys, (const void **)values, numValues, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    ABMultiValueIdentifier identifier;
    ABMultiValueAddValueAndLabel(address, aDict, kABHomeLabel, &identifier);
    CFRelease(aDict);
    ABRecordSetValue(record, kABPersonAddressProperty, address, nil);
    CFRelease(address);

    // add zip and country fields
    if (!obscure) {
        NSString *firstName = [self.selectedItem[@"name"] componentsSeparatedByString:@" "].firstObject;
        NSString *lastName = [self.selectedItem[@"name"] componentsSeparatedByString:@" "].lastObject;

        // phone
        ABMutableMultiValueRef phone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABRecordSetValue(record, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), nil);
        ABRecordSetValue(record, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName), nil);
        ABMultiValueAddValueAndLabel(phone, (__bridge CFTypeRef)(self.selectedItem[@"phone"]), kABPersonPhoneMainLabel, nil);
        ABRecordSetValue(record, kABPersonPhoneProperty, phone, nil);
        CFRelease(phone);

        // email
        ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABRecordSetValue(record, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), nil);

        ABRecordSetValue(record, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName), nil);
        ABMultiValueAddValueAndLabel(email, (__bridge CFTypeRef)(self.selectedItem[@"email"]), kABPersonPhoneMainLabel, nil);
        ABRecordSetValue(record, kABPersonEmailProperty, email, nil);

        CFRelease(email);
    }
    return CFAutorelease(record);
}

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
- (PKContact *)pkContactForSelectedItemObscure:(BOOL)obscure {
    id item = self.selectedItem;
    PKContact *contact = [[PKContact alloc] init];
    
    CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc] init];
    if(!obscure) {
        postalAddress.street = item[@"line1"];
    }
    postalAddress.city = item[@"city"];
    postalAddress.state = item[@"state"];
    postalAddress.postalCode = item[@"zip"];
    postalAddress.country = item[@"country"];
    postalAddress.ISOCountryCode = item[@"countryCode"];
    contact.postalAddress = postalAddress;
    
    if(!obscure) {
        NSPersonNameComponents *personName = [[NSPersonNameComponents alloc] init];
        personName.givenName = [item[@"name"] componentsSeparatedByString:@" "].firstObject;
        personName.familyName = [item[@"name"] componentsSeparatedByString:@" "].lastObject;
        contact.name = personName;
        
        contact.phoneNumber = [CNPhoneNumber phoneNumberWithStringValue:item[@"phone"]];
        contact.emailAddress = item[@"email"];
    }
    return contact;
}
#endif

@end

