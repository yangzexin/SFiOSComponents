//
//  SFQQAuthorization.m
//  SFShareKit
//
//  Created by yangzexin on 12/17/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFQQAuthorization.h"
#import <TencentOpenAPI/sdkdef.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentMessageObject.h>
#import "TencentLoginView.h"

@interface SFQQAuthorizationResult ()

@property (nonatomic, strong) TencentOAuth *oauth;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) BOOL cancelled;
@property (nonatomic, assign, getter = isSuccess) BOOL success;

@end

@implementation SFQQAuthorizationResult

@end

@implementation SFQQAuthRestorable

@end

@interface SFQQAuthorization () <TencentSessionDelegate, TencentLoginViewDelegate>

@property (nonatomic, copy) SFQQAuthorizationCompletion completion;
@property (nonatomic, strong) TencentOAuth *oauth;
@property (nonatomic, strong) TencentLoginView *loginView;

@end

@implementation SFQQAuthorization

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_oauth cancel:nil];
}

+ (instancetype)qqAuthWithAppId:(NSString *)appId
{
    return [self qqAuthWithAppId:appId restorable:nil];
}

+ (instancetype)qqAuthWithAppId:(NSString *)appId restorable:(SFQQAuthRestorable *)restorable
{
    static SFQQAuthorization *auth = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        auth = [[SFQQAuthorization alloc] initWithAppId:appId];
    });
    [auth.oauth setAccessToken:restorable.accessToken];
    [auth.oauth setOpenId:restorable.openId];
    [auth.oauth setExpirationDate:restorable.expirationDate];
    return auth;
}

- (id)initWithAppId:(NSString *)appId
{
    self = [super init];
    
    self.oauth = [[TencentOAuth alloc] initWithAppId:appId andDelegate:self];
    
    return self;
}

- (void)authorizeWithCompletion:(SFQQAuthorizationCompletion)completion
{
    self.completion = completion;
    
    NSArray *permissions = @[
                             kOPEN_PERMISSION_ADD_SHARE
                             , kOPEN_PERMISSION_GET_SIMPLE_USER_INFO
                             , kOPEN_PERMISSION_ADD_TOPIC
                             , kOPEN_PERMISSION_ADD_PIC_T
                             ];
    if ([TencentOAuth iphoneQQInstalled]) {
        _oauth.sessionDelegate = self;
        if ([_oauth isSessionValid]) {
            [self _notifyCompletionWithOpenId:_oauth.openId token:_oauth.accessToken success:YES cancelled:NO];
        } else {
            [_oauth authorize:permissions inSafari:YES];
        }
    } else {
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"token", @"response_type",
                                       self.oauth.appId, @"client_id",
                                       @"user_agent", @"type",
                                       @"www.qq.com", @"redirect_uri",
                                       @"mobile", @"display",
                                       [NSString stringWithFormat:@"%f",[[[UIDevice currentDevice] systemVersion] floatValue]],@"status_os",
                                       [[UIDevice currentDevice] name],@"status_machine",
                                       @"v2.0",@"status_version",
                                       [permissions componentsJoinedByString:@","], @"scope",
                                       nil];
        
        self.loginView = [[TencentLoginView alloc] initWithURL:@"https://graph.qq.com/oauth2.0/authorize" params:params delegate:self];
        [self.loginView show];
        __weak typeof(self) weakSelf = self;
        [self.loginView setDidDismiss:^{
            __strong typeof(weakSelf) self = weakSelf;
            self.loginView = nil;
        }];
    }
}

+ (BOOL)isQQInstalled
{
    return [TencentOAuth iphoneQQInstalled];
}

- (void)cancel
{
    self.completion = nil;
}

+ (void)notifyAuthorizationResultURL:(NSURL *)url
{
    [TencentOAuth HandleOpenURL:url];
}

- (void)_notifyCompletionWithOpenId:(NSString *)openId token:(NSString *)token success:(BOOL)success cancelled:(BOOL)cancelled
{
    SFQQAuthorizationResult *result = [SFQQAuthorizationResult new];
    result.userId = openId;
    result.token = token;
    result.success = success;
    result.oauth = _oauth;
    result.cancelled = cancelled;
    if (_completion) {
        _completion(result);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.completion = nil;
    });
}

- (void)tencentDidLogin
{
    if (_oauth.openId.length != 0) {
        [self _notifyCompletionWithOpenId:_oauth.openId token:_oauth.accessToken success:YES cancelled:NO];
    } else {
        [self _notifyCompletionWithOpenId:nil token:nil success:NO cancelled:NO];
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    [self _notifyCompletionWithOpenId:nil token:nil success:NO cancelled:YES];
}

- (void)tencentDidNotNetWork
{
    [self _notifyCompletionWithOpenId:nil token:nil success:NO cancelled:NO];
}

- (BOOL)onTencentReq:(TencentApiReq *)req
{
    return YES;
}

- (BOOL)onTencentResp:(TencentApiResp *)resp
{
    return YES;
}

#pragma mark - TencentLoginViewDelegate
- (void)dialogDidComplete:(TencentLoginView *)dialog
{
}

- (void)dialogCompleteWithUrl:(NSURL *)url
{
}

- (void)dialogDidNotCompleteWithUrl:(NSURL *)url
{
}

- (void)dialogDidNotComplete:(TencentLoginView *)dialog
{
}

- (void)dialog:(TencentLoginView*)dialog didFailWithError:(NSError *)error
{
    [self _notifyCompletionWithOpenId:nil token:nil success:NO cancelled:NO];
}

- (void)tencentDialogLogin:(NSString*)token openId:(NSString *)openId expirationDate:(NSDate*)expirationDate
{
    [self.loginView dismiss:YES];
    self.oauth.openId = openId;
    self.oauth.accessToken = token;
    self.oauth.expirationDate = expirationDate;
    [self _notifyCompletionWithOpenId:openId token:token success:YES cancelled:NO];
}

- (void)tencentDialogNotLogin:(BOOL)cancelled
{
    if (!cancelled) {
        [self.loginView dismiss:YES];
    }
    [self _notifyCompletionWithOpenId:nil token:nil success:NO cancelled:cancelled];
}

@end
