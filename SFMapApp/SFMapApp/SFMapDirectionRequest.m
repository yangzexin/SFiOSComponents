//
//  MapDirectionRequest.m
//  SimpleFramework
//
//  Created by yangzexin on 8/28/13.
//  Copyright (c) 2013 SimpleFramework. All rights reserved.
//

#import "SFMapDirectionRequest.h"

@implementation SFMapDirectionRequest

- (void)dealloc
{
    [_sourceApplicationName release];
    [_sourceApplicationCallbackScheme release];
    
    [_fromAddress release];
    [_toAddress release];
    [_fromPhoneNumber release];
    [_toPhoneNumber release];
    [_fromCityName release];
    [_toCityName release];
    [_controllable release];
    [super dealloc];
}

@end
