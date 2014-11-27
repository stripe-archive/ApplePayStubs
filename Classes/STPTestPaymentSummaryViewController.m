//
//  STPTestPaymentSummaryViewController.m
//  StripeExample
//
//  Created by Jack Flintermann on 9/8/14.
//  Copyright (c) 2014 Stripe. All rights reserved.
//

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

#import "STPTestPaymentSummaryViewController.h"
#import "STPTestDataTableViewController.h"
#import "STPTestCardStore.h"
#import "STPTestAddressStore.h"
#import "STPTestShippingMethodStore.h"
#import "PKPayment+STPTestKeys.h"

@interface PKPaymentAuthorizationFooterView : UIView {

}

- (void)setState:(int)arg1;

@end

NSString *const STPTestPaymentAuthorizationSummaryItemIdentifier = @"STPTestPaymentAuthorizationSummaryItemIdentifier";
NSString *const STPTestPaymentAuthorizationTestDataIdentifier = @"STPTestPaymentAuthorizationTestDataIdentifier";
NSString *const STPTestPaymentAuthorizationTestTotalDataIdentifier = @"STPTestPaymentAuthorizationTestTotalDataIdentifier";

NSString *const STPTestPaymentSectionTitleCards = @"Card";
NSString *const STPTestPaymentSectionTitleBillingAddress = @"Billing";
NSString *const STPTestPaymentSectionTitleShippingAddress = @"Shipping";
NSString *const STPTestPaymentSectionTitleShippingMethod = @"Method";
NSString *const STPTestPaymentSectionTitlePayment = @"Payment";
NSString *const STPTestPaymentSectionTitleTotalPayment = @"Total";

@interface STPTestPaymentSummaryItemCell : UITableViewCell
@end

@interface STPTestPaymentDataCell : UITableViewCell
@end

@interface STPTestPaymentTotalDataCell : STPTestPaymentDataCell
@end

@interface STPTestPaymentSummaryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) PKPaymentRequest *paymentRequest;
@property (nonatomic) NSArray *summaryItems;
@property (nonatomic) PKPaymentAuthorizationFooterView *footerView;
@property (nonatomic) STPTestCardStore *cardStore;
@property (nonatomic) STPTestAddressStore *billingAddressStore;
@property (nonatomic) STPTestAddressStore *shippingAddressStore;
@property (nonatomic) STPTestShippingMethodStore *shippingMethodStore;
@property (nonatomic) NSArray *sectionTitles;
@end

@implementation STPTestPaymentSummaryViewController

- (instancetype)initWithPaymentRequest:(PKPaymentRequest *)paymentRequest {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _paymentRequest = paymentRequest;
        _summaryItems = paymentRequest.paymentSummaryItems;
        _cardStore = [STPTestCardStore new];
        _billingAddressStore = [STPTestAddressStore new];
        _shippingAddressStore = [STPTestAddressStore new];
        _shippingMethodStore = [[STPTestShippingMethodStore alloc] initWithShippingMethods:paymentRequest.shippingMethods];
    }
    return self;
}

- (void)updateSectionTitles {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:STPTestPaymentSectionTitleCards];
    if (self.paymentRequest.requiredBillingAddressFields != PKAddressFieldNone) {
        [array addObject:STPTestPaymentSectionTitleBillingAddress];
    }
    if (self.paymentRequest.requiredShippingAddressFields != PKAddressFieldNone) {
        [array addObject:STPTestPaymentSectionTitleShippingAddress];
    }
    if (self.shippingMethodStore.allItems.count) {
        [array addObject:STPTestPaymentSectionTitleShippingMethod];
    }
    [array addObject:STPTestPaymentSectionTitlePayment];
	[array addObject:STPTestPaymentSectionTitleTotalPayment];
    self.sectionTitles = [array copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateSectionTitles];
	self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[STPTestPaymentSummaryItemCell class] forCellReuseIdentifier:STPTestPaymentAuthorizationSummaryItemIdentifier];
    [self.tableView registerClass:[STPTestPaymentDataCell class] forCellReuseIdentifier:STPTestPaymentAuthorizationTestDataIdentifier];
	[self.tableView registerClass:[STPTestPaymentTotalDataCell class] forCellReuseIdentifier:STPTestPaymentAuthorizationTestTotalDataIdentifier];
	
    if (self.paymentRequest.requiredShippingAddressFields != PKAddressFieldNone) {
        [self didSelectShippingAddress];
    }
	
	UIView *container = [[UIView alloc] initWithFrame:CGRectMake(375/2, 517, 0, 200)];
	container.backgroundColor = [UIColor purpleColor];
	self.footerView = [[PKPaymentAuthorizationFooterView alloc] initWithFrame:CGRectZero];
	
	UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 400, 375, 200)];;
	[self.view addSubview:view1];

    UITapGestureRecognizer *touchOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makePayment:)];

	[touchOnView setNumberOfTapsRequired:1];
	[touchOnView setNumberOfTouchesRequired:1];
	[view1 addGestureRecognizer:touchOnView];
	
	[self.footerView setTranslatesAutoresizingMaskIntoConstraints:YES];
	[self.footerView setState:0];
	[self.footerView setFrame:CGRectZero];
	
	[container addSubview:self.footerView];
	[self.view addSubview:container];
	
	UIButton *button = [[UIButton alloc] init];
	
	[button setTitle:@"Cancel" forState:UIControlStateNormal];
	[button setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
	
	[button sizeToFit];
	
	CGRect frame = button.frame;
	frame.size.height += 1;
	button.frame = frame;
	
	UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithCustomView:button];
	self.navigationItem.rightBarButtonItem = fixed;
	
	//[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (IBAction)makePayment:(id)sender {
    self.footerView.state = 4;
    
    PKPayment *payment = [PKPayment new];
    NSDictionary *card = self.cardStore.selectedItem;

    payment.stp_testCardNumber = card[@"number"];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([payment respondsToSelector:@selector(setShippingMethod:)] && self.shippingMethodStore.selectedItem) {
        [payment performSelector:@selector(setShippingMethod:) withObject:self.shippingMethodStore.selectedItem];
    }
    ABRecordRef shippingRecord = [self.shippingAddressStore contactForSelectedItemObscure:NO];
    if ([payment respondsToSelector:@selector(setShippingAddress:)] && shippingRecord) {
        [payment performSelector:@selector(setShippingAddress:) withObject:(__bridge id)(shippingRecord)];
    }
    ABRecordRef billingRecord = [self.billingAddressStore contactForSelectedItemObscure:NO];
    if ([payment respondsToSelector:@selector(setBillingAddress:)] && billingRecord) {
        [payment performSelector:@selector(setBillingAddress:) withObject:(__bridge id)(billingRecord)];
    }
#pragma clang diagnostic pop

    PKPaymentAuthorizationViewController *auth = (PKPaymentAuthorizationViewController *)self;
    [self.delegate paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)auth
                                  didAuthorizePayment:payment
                                           completion:^(PKPaymentAuthorizationStatus status) {
                                               self.footerView.state = 5;
                                               [self.delegate paymentAuthorizationViewControllerDidFinish:auth];
                                           }];
}

- (IBAction)cancel:(id)sender {
    [self.delegate paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)self];
	
	
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitles[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	NSString *title = self.sectionTitles[section];
	if ([title isEqualToString:STPTestPaymentSectionTitlePayment]) {
		return 16.0;
	}
	if ([title isEqualToString:STPTestPaymentSectionTitleTotalPayment]) {
		return 16.0;
	}
	else {
		return 0.5;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	NSString *title = self.sectionTitles[section];
	if (![title isEqualToString:STPTestPaymentSectionTitleTotalPayment]) {
		return 0;
	}
	else {
		return 0.5;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] init];
	NSString *title = self.sectionTitles[section];
	
	if (![title isEqualToString:STPTestPaymentSectionTitleTotalPayment]) {
		return nil;
	}
	
	CGFloat x = 16.0;
	
	UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(x, 0, tableView.frame.size.width, 0.5)];
	
	separator.backgroundColor = tableView.separatorColor;
	
	[view addSubview:separator];
	
	return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] init];
	NSString *title = self.sectionTitles[section];
	
	CGFloat x = 16.0;
	
	if (section == 0 || title == STPTestPaymentSectionTitlePayment) {
		x = 0;
	}
	
	UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(x, 0, tableView.frame.size.width, 0.5)];
	
	if ([title isEqualToString:STPTestPaymentSectionTitleTotalPayment]) {
		separator.frame = CGRectMake(x, 15.0, tableView.frame.size.width, 0.5);
	}
	
	separator.backgroundColor = tableView.separatorColor;
	
	[view addSubview:separator];
	
	return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *title = self.sectionTitles[section];
	
	if ([title isEqualToString:STPTestPaymentSectionTitlePayment]) {
        return self.summaryItems.count - 1;
    }
	else if ([title isEqualToString:STPTestPaymentSectionTitleTotalPayment]) {
		return 1;
	}
	
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.sectionTitles[indexPath.section];
	NSString *identifier;
	
	if ([title isEqualToString:STPTestPaymentSectionTitlePayment]) {
		identifier = STPTestPaymentAuthorizationTestDataIdentifier;
	}
	else if ([title isEqualToString:STPTestPaymentSectionTitleTotalPayment]) {
		identifier = STPTestPaymentAuthorizationTestTotalDataIdentifier;
	}
	else {
		identifier = STPTestPaymentAuthorizationSummaryItemIdentifier;
	}
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.sectionTitles[indexPath.section];
    if ([title isEqualToString:STPTestPaymentSectionTitlePayment] || [title isEqualToString:STPTestPaymentSectionTitleTotalPayment]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        PKPaymentSummaryItem *item = self.summaryItems[indexPath.row];
        NSString *text = [item.label uppercaseString];
        if (indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section] - 1) {
            if (text == nil) {
                text = @"";
            }
            text = [@"PAY " stringByAppendingString:text];
        }
        cell.textLabel.text = text;

		NSNumberFormatter *_currencyFormatter = [[NSNumberFormatter alloc] init];
		[_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[_currencyFormatter setCurrencyCode:self.paymentRequest.currencyCode];
		[_currencyFormatter setNegativeFormat:@"-¤#,##0.00"];
		
		cell.detailTextLabel.text = [_currencyFormatter stringFromNumber:item.amount];
		
        return;
    }

    id<STPTestDataStore> store = [self storeForSection:title];
    NSArray *descriptions = [store descriptionsForItem:store.selectedItem];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	NSString *line1 = [descriptions[0] uppercaseString];
	NSString *line2 = [descriptions[1] uppercaseString];
	
	
    cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@", line1, line2];
	
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:cell.textLabel.text attributes:nil];
	
	NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
	[paragrahStyle setLineSpacing:0.5];
	[attributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [cell.textLabel.text length])];
	
	cell.textLabel.attributedText = attributedString ;
	cell.textLabel.numberOfLines = 0;
	
    cell.detailTextLabel.text = [title uppercaseString];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.sectionTitles[indexPath.section];
    if ([title isEqualToString:STPTestPaymentSectionTitlePayment]) {
        return 19.0f;
    }
	else if ([title isEqualToString:STPTestPaymentSectionTitleTotalPayment]) {
		return 48.0f;
	}
    return 57.5f;
}

- (id<STPTestDataStore>)storeForSection:(NSString *)section {
    id<STPTestDataStore> store;
    if ([section isEqualToString:STPTestPaymentSectionTitleCards]) {
        store = self.cardStore;
    }
    if ([section isEqualToString:STPTestPaymentSectionTitleShippingAddress]) {
        store = self.shippingAddressStore;
    }
    if ([section isEqualToString:STPTestPaymentSectionTitleBillingAddress]) {
        store = self.billingAddressStore;
    }
    if ([section isEqualToString:STPTestPaymentSectionTitleShippingMethod]) {
        store = self.shippingMethodStore;
    }
    return store;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section != [tableView numberOfSections] - 1;
}

- (void)didSelectShippingAddress {
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizationViewController:didSelectShippingAddress:completion:)]) {
        self.tableView.userInteractionEnabled = NO;
        ABRecordRef record = [self.shippingAddressStore contactForSelectedItemObscure:YES];
        [self.delegate paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)self
                                 didSelectShippingAddress:record
                                               completion:^(PKPaymentAuthorizationStatus status, NSArray *shippingMethods, NSArray *summaryItems) {
                                                   if (status == PKPaymentAuthorizationStatusFailure) {
                                                       self.footerView.state = 6;
                                                       [self.delegate paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)self];
                                                       return;
                                                   }
                                                   self.summaryItems = summaryItems;
                                                   [self.shippingMethodStore setShippingMethods:shippingMethods];
                                                   [self updateSectionTitles];
                                                   [self.tableView reloadData];
                                                   self.tableView.userInteractionEnabled = YES;
                                               }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    id<STPTestDataStore> store = [self storeForSection:self.sectionTitles[indexPath.section]];
    STPTestDataTableViewController *controller = [[STPTestDataTableViewController alloc] initWithStore:store];
    if (store == self.shippingAddressStore) {
        controller.callback = ^void(id item) { [self didSelectShippingAddress]; };
    }
    if (store == self.shippingMethodStore) {
        controller.callback = ^void(id item) {
            if ([self.delegate respondsToSelector:@selector(paymentAuthorizationViewController:didSelectShippingMethod:completion:)]) {
                self.tableView.userInteractionEnabled = NO;
                PKPaymentAuthorizationViewController *vc = (PKPaymentAuthorizationViewController *)self;
                [self.delegate paymentAuthorizationViewController:vc
                                          didSelectShippingMethod:item
                                                       completion:^(PKPaymentAuthorizationStatus status, NSArray *summaryItems) {
                                                           if (status == PKPaymentAuthorizationStatusFailure) {
                                                               [self.delegate paymentAuthorizationViewControllerDidFinish:vc];
                                                               return;
                                                           }
                                                           self.summaryItems = summaryItems;
                                                           [self updateSectionTitles];
                                                           [self.tableView reloadData];
                                                           self.tableView.userInteractionEnabled = YES;
                                                       }];
            }
        };
    }
	
    [self.navigationController pushViewController:controller animated:YES];
}

@end

@implementation STPTestPaymentSummaryItemCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
		self.contentView.backgroundColor = [UIColor clearColor];
		
		self.textLabel.font = [UIFont systemFontOfSize:13.0];
		self.textLabel.numberOfLines = 2;
		self.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		UIButton *accessory = self.subviews[1];
		UIImageView *imageView = accessory.subviews[0];
		
		imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	self.detailTextLabel.frame = CGRectMake(16, self.textLabel.frame.origin.y + 1, self.detailTextLabel.frame.size.width, self.detailTextLabel.frame.size.height);
	
	self.textLabel.frame = CGRectMake(111, self.textLabel.frame.origin.y + 1, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
	
	UIButton *accessory = self.subviews[1];
	
	CGRect frame = accessory.frame;
	frame.origin.x--;
	accessory.frame = frame;
}
@end

@implementation STPTestPaymentDataCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
		self.contentView.backgroundColor = [UIColor clearColor];
		self.textLabel.font = [UIFont systemFontOfSize:13.0];
		self.textLabel.textColor = self.detailTextLabel.textColor;
		
        self.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
		self.detailTextLabel.textColor = [UIColor blackColor];
    }
    return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	self.textLabel.frame = CGRectMake(111, self.textLabel.frame.origin.y, 200, self.textLabel.frame.size.height);
}
@end

@implementation STPTestPaymentTotalDataCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
	if (self) {
		self.textLabel.textColor = [UIColor blackColor];
		self.detailTextLabel.font = [UIFont systemFontOfSize:20.0];

	}
	return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	CGRect frame = self.textLabel.frame;
    self.textLabel.frame = CGRectOffset(frame, 0, -4);
    
	frame = self.detailTextLabel.frame;
    self.detailTextLabel.frame = CGRectOffset(frame, 0, -4);
}
@end

#endif
