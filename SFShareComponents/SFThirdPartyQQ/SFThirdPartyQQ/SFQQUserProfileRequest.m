//
//  SFQQUserProfileRequest.m
//  SFThirdPartyQQ
//
//  Created by yangzexin on 6/12/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFQQUserProfileRequest.h"

@interface SFQQUserProfileRequest () <TencentSessionDelegate>

@property (nonatomic, strong) TencentOAuth *tencentOAuth;
@property (nonatomic, copy) SFQQUserProfileRequestCompletion completion;

@end

@implementation SFQQUserProfileRequest

+ (instancetype)requestWithTencentOAuth:(TencentOAuth *)tencentOAuth
{
    SFQQUserProfileRequest *request = [SFQQUserProfileRequest new];
    request.tencentOAuth = tencentOAuth;
    
    return request;
}

- (void)requestWithCompletion:(SFQQUserProfileRequestCompletion)completion
{
    self.completion = completion;
    _tencentOAuth.sessionDelegate = self;
    [_tencentOAuth getUserInfo];
}

- (void)cancel
{
    self.completion = nil;
}

- (void)getUserInfoResponse:(APIResponse *)response
{
    NSNumber *ret = [response.jsonResponse objectForKey:@"ret"];
    if (ret && [ret integerValue] == 0) {
        if (self.completion) {
            self.completion(response.jsonResponse, nil);
        }
    } else {
        if (self.completion) {
            self.completion(nil, [NSError errorWithDomain:NSStringFromClass([self class]) code:-1 userInfo:nil]);
        }
    }
}

- (void)tencentDidLogin
{
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
}

- (void)tencentDidNotNetWork
{
}

@end
