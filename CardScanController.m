//
//  CardScanController.m
//  Stripe Test App
//
//  Created by Mitchell Porter on 5/22/15.
//  Copyright (c) 2015 Mitchell Porter. All rights reserved.
//

#import "CardScanController.h"
#import "ResponseSerializer.h"
#import <Stripe/Stripe.h>
#import <AFNetworking/AFNetworking.h>

static NSString *testSecretKey = @"sk_test_mUZyJO28o0UNCdZY7jPMuHN1";
static NSString *testPublishableKey = @"pk_test_Hw6EKSIAY4mw5XfiywNs0KiB";
static NSString *herokuURL = @"https://stripe-ios-backend.herokuapp.com";
static NSString *mastercardDebitTestCard = @"5200828282828210";

@interface CardScanController () <CardIOPaymentViewControllerDelegate, STPBackendCharging>

// CardIO
@property NSString *cardNumber;
@property NSUInteger expiryMonth;
@property NSUInteger expiryYear;
@property NSString *cvv;

// Stripe

@end

@implementation CardScanController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self createRecipient];
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
    
    [scanViewController dismissViewControllerAnimated:YES completion:^{
        // Create stripe token
        [self createStripeToken];
        
    }];
}

# pragma mark - Stripe

- (void)createStripeToken
{
    STPCard *card = [[STPCard alloc] init];
//    card.number = self.cardNumber;
    card.number = mastercardDebitTestCard;
    card.expMonth = self.expiryMonth;
    card.expYear = self.expiryYear;
    card.cvc = self.cvv;
    
    STPAPIClient *client = [[STPAPIClient alloc] initWithPublishableKey:testPublishableKey];
    
    [client createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        
        if (error) {
            // Handle error
        } else {
            
            [self createBackendChargeWithToken:token completion:^(STPBackendChargeResult status, NSError * __nullable error) {
                //
            }];
        }
        
    }];
}


- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion {
    NSDictionary *chargeParams = @{ @"stripeToken": token.tokenId, @"amount": @"1000" };
    
    if (!herokuURL) {
        NSError *error = [NSError
                          errorWithDomain:StripeDomain
                          code:STPInvalidRequestError
                          userInfo:@{
                                     NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Good news! Stripe turned your credit card into a token: %@ \nYou can follow the "
                                                                 @"instructions in the README to set up an example backend, or use this "
                                                                 @"token to manually create charges at dashboard.stripe.com .",
                                                                 token.tokenId]
                                     }];
        completion(STPBackendChargeResultFailure, error);
        return;
    }
    
    // This passes the token off to our payment backend, which will then actually complete charging the card using your Stripe account's secret key
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:[herokuURL stringByAppendingString:@"/charge"]
       parameters:chargeParams
          success:^(AFHTTPRequestOperation *operation, id responseObject) { completion(STPBackendChargeResultSuccess, nil);
          
          }
     
          failure:^(AFHTTPRequestOperation *operation, NSError *error) { completion(STPBackendChargeResultFailure, error);
          
          
          }];
}

- (void)createManagedConnectAccount
{
    NSDictionary *chargeParams = @{@"country": @"US", @"managed": @"true"};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:[testSecretKey stringByAppendingString:@":"] password:@""];
    manager.responseSerializer = [ResponseSerializer serializer];
    [manager POST:[NSString stringWithFormat:@"https://api.stripe.com/v1/accounts"]
       parameters:chargeParams
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
          }
     
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
       }];
}

- (void)createRecipient
{
    // Testing - hardcoded
    self.expiryMonth = 04;
    self.expiryYear = 18;
    
    NSDictionary *chargeParams = @{@"name": @"Mitchell Porter", @"type": @"individual", @"card": @{@"number": mastercardDebitTestCard, @"exp_month": [NSString stringWithFormat:@"%lu", self.expiryMonth], @"exp_year": [NSString stringWithFormat:@"%lu", self.expiryYear]}};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:[testSecretKey stringByAppendingString:@":"] password:@""];
    manager.responseSerializer = [ResponseSerializer serializer];
    [manager POST:[NSString stringWithFormat:@"https://api.stripe.com/v1/recipients"]
       parameters:chargeParams
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
          }
     
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
          }];
}

@end
