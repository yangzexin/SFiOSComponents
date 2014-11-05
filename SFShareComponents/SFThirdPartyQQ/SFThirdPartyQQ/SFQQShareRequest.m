    //
//  SFQQShareRequest.m
//  SFThirdPartyQQ
//
//  Created by yangzexin on 6/4/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFQQShareRequest.h"

NSInteger const SFQQShareRequestErrorCodeSendFail = -1;
NSInteger const SFQQShareRequestErrorCodeShareFail = -2;

@interface SFQQShareRequest () <TCAPIRequestDelegate>

@property (nonatomic, strong) TencentOAuth *tencentOAuth;
@property (nonatomic, strong) TCAPIRequest *request;

@property (nonatomic, copy) SFQQShareRequestCompletion completion;

@end

@implementation SFQQShareRequest

- (void)dealloc
{
    [self.request cancel];
}

+ (instancetype)requestWithTencentOAuth:(TencentOAuth *)tencentOAuth
{
    SFQQShareRequest *request = [SFQQShareRequest new];
    request.tencentOAuth = tencentOAuth;
    
    return request;
}

- (void)shareWithRequest:(TCAPIRequest *)request completion:(SFQQShareRequestCompletion)completion
{
    BOOL sended = [self.tencentOAuth sendAPIRequest:request callback:self];
    if (!sended) {
        if (completion) {
            completion(NO, [NSError errorWithDomain:NSStringFromClass([self class]) code:SFQQShareRequestErrorCodeSendFail userInfo:@{NSLocalizedDescriptionKey : @"send request failed"}]);
        }
    } else {
        self.request = request;
        self.completion = completion;
    }
}

- (void)cancel
{
    [self.request cancel];
    self.completion = nil;
}

#pragma mark - TCAPIRequestDelegate
- (void)cgiRequest:(TCAPIRequest *)request didResponse:(APIResponse *)response
{
    NSInteger code = [[[response jsonResponse] objectForKey:@"ret"] integerValue];
    if (self.completion) {
        BOOL success = code == 0;
        self.completion(success, success ? nil : [NSError errorWithDomain:NSStringFromClass([self class]) code:SFQQShareRequestErrorCodeShareFail userInfo:@{NSLocalizedDescriptionKey : @"share failed"}]);
    }
}

@end
