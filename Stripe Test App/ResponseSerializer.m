//
//  ResponseSerializer.m
//  Stripe Test App
//
//  Created by Mitchell Porter on 5/23/15.
//  Copyright (c) 2015 Mitchell Porter. All rights reserved.
//

#import "ResponseSerializer.h"

@implementation ResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    return JSONDictionary;
}

@end
