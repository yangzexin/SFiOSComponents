//
//  SFSinaWeiboAuthorizationRequest.h
//  SFShareKit
//
//  Created by yangzexin on 12/17/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFSinaWeiboAuthorizationResult;

OBJC_EXPORT NSString *SFSinaWeiboAuthorizationHandleOpenURLNotification;

typedef void(^SFSinaWeiboAuthorizationCompletion)(SFSinaWeiboAuthorizationResult *result);

@interface SFSinaWeiboAuthorizationRequest : NSObject

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *redirectURLString;

+ (instancetype)requestWithAppKey:(NSString *)appKey redirectURLString:(NSString *)redirectURLString;

@end

@interface SFSinaWeiboAuthorizationResult : NSObject

@property (nonatomic, copy, readonly) NSString *userID;
@property (nonatomic, copy, readonly) NSString *token;

@property (nonatomic, assign, readonly, getter = isSuccess) BOOL success;
@property (nonatomic, copy, readonly) NSString *message;

@end

@protocol SFSinaWeiboAuthorization <NSObject>

- (void)authorizeWithRequest:(SFSinaWeiboAuthorizationRequest *)request completion:(SFSinaWeiboAuthorizationCompletion)completion;

@end

@interface SFSinaWeiboAuthorization : NSObject <SFSinaWeiboAuthorization>

@property (nonatomic, assign) BOOL disableNotificationObserving;

- (void)notifyAuthorizationResultURL:(NSURL *)url;

+ (instancetype)authorization;

@end
