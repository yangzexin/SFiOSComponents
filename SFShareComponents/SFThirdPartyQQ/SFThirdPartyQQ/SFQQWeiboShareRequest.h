//
//  SFQQWeiboShareRequest.h
//  SFThirdPartyQQ
//
//  Created by yangzexin on 6/4/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "SFQQWeiboShare.h"

typedef void(^SFQQWeiboShareRequestCompletion)(BOOL success, NSError *error);

@interface SFQQWeiboShareRequest : NSObject

+ (instancetype)requestWithTencentOAuth:(TencentOAuth *)tencentOAuth;

- (void)share:(SFQQWeiboShare *)share completion:(SFQQWeiboShareRequestCompletion)completion;
- (void)cancel;

@end
