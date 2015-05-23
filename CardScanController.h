//
//  CardScanController.h
//  Stripe Test App
//
//  Created by Mitchell Porter on 5/22/15.
//  Copyright (c) 2015 Mitchell Porter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CardIO/CardIO.h>
#import <Stripe/Stripe.h>

@protocol STPBackendCharging <NSObject>

- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion;

@end

@interface CardScanController : UIViewController



@end
