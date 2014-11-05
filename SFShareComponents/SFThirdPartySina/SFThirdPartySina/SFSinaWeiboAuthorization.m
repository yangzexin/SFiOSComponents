//
//  SFSinaWeiboAuthorizationRequest.m
//  SFShareKit
//
//  Created by yangzexin on 12/17/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFSinaWeiboAuthorization.h"
#import "WeiboSDK.h"

NSString *SFSinaWeiboAuthorizationHandleOpenURLNotification = @"SFSinaWeiboAuthorizationHandleOpenURLNotification";

@implementation SFSinaWeiboAuthorizationRequest

+ (instancetype)requestWithAppKey:(NSString *)appKey redirectURLString:(NSString *)redirectURLString
{
    SFSinaWeiboAuthorizationRequest *request = [SFSinaWeiboAuthorizationRequest new];
    request.appKey = appKey;
    request.redirectURLString = redirectURLString;
    return request;
}

@end

@interface SFSinaWeiboAuthorizationResult ()

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *token;

@property (nonatomic, assign, getter = isSuccess) BOOL success;
@property (nonatomic, copy) NSString *message;

@end

@implementation SFSinaWeiboAuthorizationResult

@end

@interface SFSinaWeiboAuthorization () <WeiboSDKDelegate>

@property (nonatomic, copy) SFSinaWeiboAuthorizationCompletion completion;

@end

@interface SFSinaWeiboAuthorization ()

@property (nonatomic, assign) BOOL authorized;

@end

@implementation SFSinaWeiboAuthorization

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)authorization
{
    SFSinaWeiboAuthorization *auth = [SFSinaWeiboAuthorization new];
    return auth;
}

- (id)init
{
    self = [super init];
    
    self.disableNotificationObserving = NO;
    
    return self;
}

- (void)authorizeWithRequest:(SFSinaWeiboAuthorizationRequest *)request completion:(SFSinaWeiboAuthorizationCompletion)completion
{
    self.completion = completion;
    
    BOOL registerSuccess = [WeiboSDK registerApp:request.appKey];
//    [WeiboSDK enableDebugMode:YES];
    if (registerSuccess == NO) {
        SFSinaWeiboAuthorizationResult *result = [SFSinaWeiboAuthorizationResult new];
        result.success = NO;
        result.message = @"注册第三方应用失败";
        [self _notifyResult:result];
    } else {
        WBAuthorizeRequest *authorizeRequest = [WBAuthorizeRequest request];
        authorizeRequest.redirectURI = request.redirectURLString;
        [WeiboSDK sendRequest:authorizeRequest];
    }
}

- (void)notifyAuthorizationResultURL:(NSURL *)url
{
    if (!self.authorized) {
        [WeiboSDK handleOpenURL:url delegate:self];
    }
}

- (void)_notifyResult:(SFSinaWeiboAuthorizationResult *)result
{
    if (_completion) {
        _completion(result);
    }
}

- (void)setDisableNotificationObserving:(BOOL)disableNotificationObserving
{
    _disableNotificationObserving = disableNotificationObserving;
    if (_disableNotificationObserving) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SFSinaWeiboAuthorizationHandleOpenURLNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sinaWeiboAuthrizationHandleOpenURLNotification:) name:SFSinaWeiboAuthorizationHandleOpenURLNotification object:nil];
    }
}

- (void)_sinaWeiboAuthrizationHandleOpenURLNotification:(NSNotification *)note
{
    [self notifyAuthorizationResultURL:note.object];
}

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    NSLog(@"Unhandled weibo request:%@", request);
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        WBAuthorizeResponse *authorizeResponse = (id)response;
        SFSinaWeiboAuthorizationResult *result = [SFSinaWeiboAuthorizationResult new];
        result.success = NO;
        if (authorizeResponse.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            self.authorized = YES;
            
            result.success = YES;
            result.userID = authorizeResponse.userID;
            result.token = authorizeResponse.accessToken;
        }
        [self _notifyResult:result];
    }
}

@end
