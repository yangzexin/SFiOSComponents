//
//  SFQQAuthorization.h
//  SFShareKit
//
//  Created by yangzexin on 12/17/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>

@class SFQQAuthorizationResult;

typedef void(^SFQQAuthorizationCompletion)(SFQQAuthorizationResult *result);

@interface SFQQAuthorizationResult : NSObject

@property (nonatomic, strong, readonly) TencentOAuth *oauth;
@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSString *token;
@property (nonatomic, assign, readonly, getter=isCancelled) BOOL cancelled;
@property (nonatomic, assign, readonly, getter = isSuccess) BOOL success;

@end

@interface SFQQAuthRestorable : NSObject

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *openId;
@property (nonatomic, strong) NSDate *expirationDate;

@end

@protocol SFQQAuthorization <NSObject>

- (void)authorizeWithCompletion:(SFQQAuthorizationCompletion)completion;

@end

@interface SFQQAuthorization : NSObject <SFQQAuthorization>

@property (nonatomic, copy) NSString *redirectURLString;

+ (instancetype)qqAuthWithAppId:(NSString *)appId;

+ (instancetype)qqAuthWithAppId:(NSString *)appId restorable:(SFQQAuthRestorable *)restorable;

+ (BOOL)isQQInstalled;

- (void)cancel;

+ (void)notifyAuthorizationResultURL:(NSURL *)url;

@end
