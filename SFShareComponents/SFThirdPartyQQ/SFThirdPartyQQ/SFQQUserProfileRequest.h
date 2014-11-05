//
//  SFQQUserProfileRequest.h
//  SFThirdPartyQQ
//
//  Created by yangzexin on 6/12/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>

typedef void(^SFQQUserProfileRequestCompletion)(NSDictionary *profile, NSError *error);

@interface SFQQUserProfileRequest : NSObject

+ (instancetype)requestWithTencentOAuth:(TencentOAuth *)tencentOAuth;

- (void)requestWithCompletion:(SFQQUserProfileRequestCompletion)completion;
- (void)cancel;

@end
