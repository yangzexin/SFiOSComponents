//
//  SFWeiboShareRequest.h
//  SFThirdPartySina
//
//  Created by yangzexin on 6/4/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFWeiboShare.h"

/// 使用该类之前须先使用SFSinaWeiboAuthorization进行授权

typedef void(^SFWeiboShareRequestCompletion)(BOOL success, NSError *error);

@interface SFWeiboShareRequest : NSObject

+ (instancetype)request;

+ (void)notifyResponseWithURL:(NSURL *)url;

- (void)share:(SFWeiboShare *)share completion:(SFWeiboShareRequestCompletion)completion;
- (void)cancel;

@end
