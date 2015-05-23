//
//  LaunchController.m
//  Stripe Test App
//
//  Created by Mitchell Porter on 5/22/15.
//  Copyright (c) 2015 Mitchell Porter. All rights reserved.
//

#import "LaunchController.h"

#pragma mark - Heroku URL

static NSString *herokuURL = @"https://stripe-ios-backend.herokuapp.com/";

@interface LaunchController ()

@end

@implementation LaunchController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (IBAction)simpleGet:(id)sender
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:herokuURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
}

@end
