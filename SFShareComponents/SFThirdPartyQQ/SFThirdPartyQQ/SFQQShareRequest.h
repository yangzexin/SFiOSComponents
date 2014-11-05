//
//  SFQQShareRequest.h
//  SFThirdPartyQQ
//
//  Created by yangzexin on 6/4/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>

typedef void(^SFQQShareRequestCompletion)(BOOL success, NSError *error);

OBJC_EXPORT NSInteger const SFQQShareRequestErrorCodeSendFail;
OBJC_EXPORT NSInteger const SFQQShareRequestErrorCodeShareFail;

@interface SFQQShareRequest : NSObject

+ (instancetype)requestWithTencentOAuth:(TencentOAuth *)tencentOAuth;

- (void)shareWithRequest:(TCAPIRequest *)request completion:(SFQQShareRequestCompletion)completion;
- (void)cancel;

@end
