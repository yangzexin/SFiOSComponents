//
//  SFQzoneShareRequest.m
//  SFThirdPartyQQ
//
//  Created by yangzexin on 6/4/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFQzoneShareRequest.h"

#import "SFQzoneShare.h"

#import <TencentOpenAPI/QQApiInterface.h>

NSInteger const SFQzoneShareRequestErrorCodeNotInstalled = -1;
NSInteger const SFQzoneShareRequestErrorCodeUnknown = -2;

NSString *const SFQzoneShareDidRecieveResponseNotification = @"SFQzoneShareDidRecieveResponseNotification";

@interface SFQzoneShareSharedDelegate : NSObject <QQApiInterfaceDelegate>

@end

@implementation SFQzoneShareSharedDelegate

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

/**
 处理来至QQ的请求
 */
- (void)onReq:(QQBaseReq *)req
{
}

/**
 处理来至QQ的响应
 */
- (void)onResp:(QQBaseResp *)resp
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SFQzoneShareDidRecieveResponseNotification object:resp];
}

/**
 处理QQ在线状态的回调
 */
- (void)isOnlineResponse:(NSDictionary *)response
{
}

@end

@interface SFQzoneShareRequest ()

@property (nonatomic, copy) SFQzoneShareRequestCompletion completion;

@end

@implementation SFQzoneShareRequest

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)request
{
    SFQzoneShareRequest *request = [SFQzoneShareRequest new];
    
    return request;
}

+ (void)notifyResponseWithURL:(NSURL *)url
{
    [QQApiInterface handleOpenURL:url delegate:[SFQzoneShareSharedDelegate sharedInstance]];
}

- (void)share:(SFQzoneShare *)share completion:(SFQzoneShareRequestCompletion)completion
{
    self.completion = completion;
    
    QQApiNewsObject *urlObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:share.url] title:share.title description:share.content previewImageData:UIImageJPEGRepresentation(share.image, 1.0f)];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:urlObj];
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    if (sent != EQQAPISENDSUCESS) {
        NSError *error = nil;
        if (sent == EQQAPIQQNOTINSTALLED) {
            error = [NSError errorWithDomain:NSStringFromClass([self class]) code:SFQzoneShareRequestErrorCodeNotInstalled userInfo:@{NSLocalizedDescriptionKey : @"not installed"}];
        } else {
            error = [NSError errorWithDomain:NSStringFromClass([self class]) code:SFQzoneShareRequestErrorCodeUnknown userInfo:@{NSLocalizedDescriptionKey : @"share failed"}];
        }
        if (self.completion) {
            self.completion(NO, error);
            self.completion = nil;
        }
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_responseNotification:) name:SFQzoneShareDidRecieveResponseNotification object:nil];
    }
}

- (void)_responseNotification:(NSNotification *)note
{
    QQBaseResp *resp = note.object;
    if ([resp.result integerValue] == 0) {
        if (self.completion) {
            self.completion(YES, nil);
            self.completion = nil;
        }
    } else {
        if (self.completion) {
            self.completion(NO, [NSError errorWithDomain:NSStringFromClass([self class]) code:SFQzoneShareRequestErrorCodeUnknown userInfo:@{NSLocalizedDescriptionKey : [resp errorDescription]}]);
            self.completion = nil;
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SFQzoneShareDidRecieveResponseNotification object:nil];
}

- (void)cancel
{
    self.completion = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SFQzoneShareDidRecieveResponseNotification object:nil];
}

@end
