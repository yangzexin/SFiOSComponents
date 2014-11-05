//
//  SFQzoneShareRequest.h
//  SFThirdPartyQQ
//
//  Created by yangzexin on 6/4/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>

@class SFQzoneShare;

typedef void(^SFQzoneShareRequestCompletion)(BOOL success, NSError *error);

OBJC_EXPORT NSInteger const SFQzoneShareRequestErrorCodeNotInstalled;
OBJC_EXPORT NSInteger const SFQzoneShareRequestErrorCodeUnknown;

@interface SFQzoneShareRequest : NSObject

+ (instancetype)request;

+ (void)notifyResponseWithURL:(NSURL *)url;

- (void)share:(SFQzoneShare *)share completion:(SFQzoneShareRequestCompletion)completion;

@end
