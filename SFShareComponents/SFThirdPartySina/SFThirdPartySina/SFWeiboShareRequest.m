//
//  SFWeiboShareRequest.m
//  SFThirdPartySina
//
//  Created by yangzexin on 6/4/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFWeiboShareRequest.h"

#import "WeiboSDK.h"

@interface SFWeiboShareRequest () <WeiboSDKDelegate>

@property (nonatomic, copy) SFWeiboShareRequestCompletion completion;

@end

@implementation SFWeiboShareRequest

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)request
{
    SFWeiboShareRequest *request = [SFWeiboShareRequest new];
    
    return request;
}

- (void)share:(SFWeiboShare *)share completion:(SFWeiboShareRequestCompletion)completion
{
    self.completion = completion;
    
    WBMessageObject *msgObj = [WBMessageObject message];
    msgObj.text = share.content.length > 140 ? [share.content substringToIndex:140] : share.content;
    msgObj.imageObject = ({
        WBImageObject *imageObj = [WBImageObject object];
        imageObj.imageData = UIImageJPEGRepresentation(share.image, 1.0f);
        imageObj;
    });
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:msgObj];
    if (![WeiboSDK sendRequest:request]) {
        if (self.completion) {
            self.completion(NO, [NSError errorWithDomain:NSStringFromClass([self class]) code:-1 userInfo:@{NSLocalizedDescriptionKey : @"send request failed"}]);
            self.completion = nil;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_callbackNotification:) name:@"__SFWeiboCallbackNotification" object:nil];
}

- (void)cancel
{
    self.completion = nil;
}

+ (void)notifyResponseWithURL:(NSURL *)url
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"__SFWeiboCallbackNotification" object:url userInfo:nil];
}

- (void)_callbackNotification:(NSNotification *)note
{
    [self _notifyResponseWithURL:note.object];
}

- (void)_notifyResponseWithURL:(NSURL *)url
{
    [WeiboSDK handleOpenURL:url delegate:self];
}

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    NSLog(@"Unhandled weibo request:%@", request);
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        WBSendMessageToWeiboResponse *sendMsgToWeiboResponse = (id)response;
        BOOL success = sendMsgToWeiboResponse.statusCode == WeiboSDKResponseStatusCodeSuccess;
        if (self.completion) {
            self.completion(success, success ? nil : [NSError errorWithDomain:NSStringFromClass([self class]) code:-1 userInfo:@{NSLocalizedDescriptionKey : @"share failed"}]);
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
