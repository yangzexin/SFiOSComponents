//
//  SFSharedWeixinHandler.h
//  SFShareKit
//
//  Created by yangzexin on 1/16/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXPORT NSString *const SFSharedWeixinHandlerNotifyNotification;

OBJC_EXPORT NSString *const SFSharedWeixinHandlerResponseNotification;
OBJC_EXPORT NSString *const SFSharedWeixinHandlerRequestNotification;

@interface SFSharedWeixinHandler : NSObject

+ (instancetype)sharedInstance;

- (void)prepareWithAppId:(NSString *)appId;

@end
