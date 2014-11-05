//
//  SFWeixinShareRequest.m
//  SFWeixinShare
//
//  Created by yangzexin on 5/23/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFWeixinShareRequest.h"

#import "WXApi.h"

#import "SFSharedWeixinHandler.h"

@interface SFWeixinShareRequest () <WXApiDelegate>

@property (nonatomic, strong) SFWeixinShareRequestCompletion completion;
@property (nonatomic, strong, readonly) UIViewController *parentViewController;
@property (nonatomic, assign) BOOL finished;

@end

@implementation SFWeixinShareRequest

+ (void)notifyCallbackWithURL:(NSURL *)url
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SFSharedWeixinHandlerNotifyNotification object:url];
}

+ (void)initWithAppId:(NSString *)appId
{
    [[SFSharedWeixinHandler sharedInstance] prepareWithAppId:appId];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)share:(SFWeixinShare *)share completion:(SFWeixinShareRequestCompletion)completion
{
    self.finished = NO;
    self.completion = completion;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_weixinResultURLRecievedNotification:) name:SFSharedWeixinHandlerResponseNotification object:nil];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = share.title;
    message.description = share.content;
    if (share.image) {
        [message setThumbImage:share.image];
    }
    
    if (share.redirectToUrl) {
        WXWebpageObject *web = [WXWebpageObject object];
        web.webpageUrl = share.url;
        message.mediaObject = web;
    } else {
        WXAppExtendObject *ext = [WXAppExtendObject object];
        ext.extInfo = share.extInfo;
        ext.url = share.url;
        NSInteger const BUFFER_SIZE = 1024;
        Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
        memset(pBuffer, 0, BUFFER_SIZE);
        NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
        free(pBuffer);
        ext.fileData = data;
        message.mediaObject = ext;
    }
    
    SendMessageToWXReq* req = [SendMessageToWXReq new];
    req.message = message;
    
    req.scene = share.type == SFWeixinShareTypeTimeline ? WXSceneTimeline : WXSceneSession;
    
    if ([WXApi isWXAppInstalled]) {
        if ([WXApi sendReq:req] == NO) {
            [self notifyWithSuccess:NO errorCode:SFWeixinShareErrorCodeSendRequestFailed];
        }
    } else {
        [self notifyWithSuccess:NO errorCode:SFWeixinShareErrorCodeNotInstalled];
    }
}

- (void)_weixinResultURLRecievedNotification:(NSNotification *)note
{
    [self onResp:note.object];
}

- (void)notifyWithSuccess:(BOOL)success errorCode:(NSInteger)errorCode
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_completion) {
        _completion(success, [NSError errorWithDomain:NSStringFromClass([self class]) code:errorCode userInfo:@{}]);
    }
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp*)resp
{
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        [self notifyWithSuccess:resp.errCode == 0 errorCode:resp.errCode == -2 ? SFWeixinShareErrorCodeUserCancelled : resp.errCode];
    }
}

- (void)onReq:(BaseReq*)req
{
    
}

@end
