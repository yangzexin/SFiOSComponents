//
//  SFWeixinShareRequest.h
//  SFWeixinShare
//
//  Created by yangzexin on 5/23/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFWeixinShare.h"

typedef void(^SFWeixinShareRequestCompletion)(BOOL success, NSError *error);

@interface SFWeixinShareRequest : NSObject

+ (void)initWithAppId:(NSString *)appId;
+ (void)notifyCallbackWithURL:(NSURL *)url;

- (void)share:(SFWeixinShare *)share completion:(SFWeixinShareRequestCompletion)completion;

@end
