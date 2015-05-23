//
//  CardScanController.m
//  Stripe Test App
//
//  Created by Mitchell Porter on 5/22/15.
//  Copyright (c) 2015 Mitchell Porter. All rights reserved.
//

#import "CardScanController.h"

@interface CardScanController () <CardIOPaymentViewControllerDelegate>

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
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
