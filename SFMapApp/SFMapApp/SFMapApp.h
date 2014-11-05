//
//  SFMapApp.h
//  SFMapApp
//
//  Created by yangzexin on 11/5/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMapDirectionRequest.h"

@protocol SFMapApp <NSObject>

- (NSString *)name;
- (BOOL)available;
- (void)directionWithRequest:(SFMapDirectionRequest *)request;

@end
