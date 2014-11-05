//
//  SFWeixinRequestCatcher.h
//  SFShareKit
//
//  Created by yangzexin on 1/14/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFWeixinRequestCatcher;

@protocol SFWeixinRequestCatcherDelegate <NSObject>

@optional
- (void)weixinRequestCatcher:(SFWeixinRequestCatcher *)weixinRequestCatcher didCatchMessage:(id)message;

@end

@interface SFWeixinRequestCatcher : NSObject

@property (nonatomic, weak) id<SFWeixinRequestCatcherDelegate> delegate;

+ (void)initWithAppId:(NSString *)appId;

@end
