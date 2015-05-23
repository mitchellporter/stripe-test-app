//
//  CardScanController.m
//  Stripe Test App
//
//  Created by Mitchell Porter on 5/22/15.
//  Copyright (c) 2015 Mitchell Porter. All rights reserved.
//

#import "CardScanController.h"
#import <Stripe/Stripe.h>

static NSString *stripeKey = @"sk_test_mUZyJO28o0UNCdZY7jPMuHN1";

@interface CardScanController () <CardIOPaymentViewControllerDelegate>

// CardIO
@property NSString *cardNumber;
@property NSUInteger expiryMonth;
@property NSUInteger expiryYear;
@property NSString *cvv;

// Stripe
@property (nonatomic, weak) id<STPBackendCharging> backendCharger;


@end

@implementation CardScanController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [CardIOUtilities preload];
}

#pragma mark - IBActions

- (IBAction)scanCard:(id)sender
{
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    [self presentViewController:scanViewController animated:YES completion:nil];
}

- (IBAction)chargeCard:(id)sender
{
    STPCard *card = [[STPCard alloc] init];
    card.number = self.cardNumber;
    card.expMonth = self.expiryMonth;
    card.expYear = self.expiryYear;
    card.cvc = self.cvv;
    
    [[STPAPIClient sharedClient] createTokenWithCard:card
                                          completion:^(STPToken *token, NSError *error) {
                                              
     if (error) {
        // Handle error
     }
                                              
      [self.backendCharger createBackendChargeWithToken:token completion:^(STPBackendChargeResult result, NSError *error) {
            if (error) {
                return;
             }
          
    }];
    }];
}

#pragma mark - Delegate methods

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController
{
    NSLog(@"User canceled payment info");
    // Handle user cancellation here...
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController
{
    // The full card number is available as info.cardNumber, but don't log that!
    NSLog(@"Received card info. Number: %@, expiry: %02lu/%lu, cvv: %@.", info.redactedCardNumber, (unsigned long)info.expiryMonth, (unsigned long)info.expiryYear, info.cvv);
    
    // Use the card info...
    self.cardNumber = info.cardNumber;
    self.expiryMonth = info.expiryMonth;
    self.expiryYear = info.expiryYear;
    self.cvv = info.cvv;
    
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
