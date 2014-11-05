//
//  SFQQWeiboShareRequest.m
//  SFThirdPartyQQ
//
//  Created by yangzexin on 6/4/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFQQWeiboShareRequest.h"

#import "SFQQShareRequest.h"

@interface SFQQWeiboShareRequest ()

@property (nonatomic, strong) SFQQShareRequest *request;

@property (nonatomic, copy) SFQQWeiboShareRequestCompletion completion;

@end

@implementation SFQQWeiboShareRequest

+ (instancetype)requestWithTencentOAuth:(TencentOAuth *)tencentOAuth
{
    SFQQWeiboShareRequest *request = [SFQQWeiboShareRequest new];
    request.request = [SFQQShareRequest requestWithTencentOAuth:tencentOAuth];
    
    return request;
}

- (void)share:(SFQQWeiboShare *)share completion:(SFQQWeiboShareRequestCompletion)completion
{
    self.completion = completion;
    
    WeiBo_add_pic_t_POST *post = [WeiBo_add_pic_t_POST new];
    post.param_content = share.content;
    post.param_latitude = [NSString stringWithFormat:@"%f", share.latitude];
    post.param_longitude = [NSString stringWithFormat:@"%f", share.longitude];
    post.param_pic = share.image;
    
    __weak typeof(self) weakSelf = self;
    [self.request shareWithRequest:post completion:^(BOOL success, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (self.completion) {
            self.completion(success, error);
            self.completion = nil;
        }
    }];
}

- (void)cancel
{
    [self.request cancel];
    self.completion = nil;
}

@end
