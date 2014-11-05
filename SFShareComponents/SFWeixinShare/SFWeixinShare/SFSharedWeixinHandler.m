//
//  SFSharedWeixinHandler.m
//  SFShareKit
//
//  Created by yangzexin on 1/16/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFSharedWeixinHandler.h"
#import "WXApi.h"

NSString *const SFSharedWeixinHandlerNotifyNotification = @"SFWeixinRequestCatcherNotifyNotification";

NSString *const SFSharedWeixinHandlerResponseNotification = @"SFSharedWeixinHandlerResponseNotification";
NSString *const SFSharedWeixinHandlerRequestNotification = @"SFSharedWeixinHandlerRequestNotification";

@interface SFSharedWeixinHandler () <WXApiDelegate>

@end

@implementation SFSharedWeixinHandler

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

- (void)prepareWithAppId:(NSString *)appId
{
    [WXApi registerApp:appId];
}

- (id)init
{
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_notifyNotification:) name:SFSharedWeixinHandlerNotifyNotification object:nil];
    
    return self;
}

- (void)_notifyNotification:(NSNotification *)note
{
    [self handleOpenURL:note.object];
}

- (void)handleOpenURL:(NSURL *)url
{
    [WXApi handleOpenURL:url delegate:self];
}

-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[ShowMessageFromWXReq class]]){
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        [[NSNotificationCenter defaultCenter] postNotificationName:SFSharedWeixinHandlerRequestNotification object:temp.message];
    }
}

-(void) onResp:(BaseResp*)resp
{
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SFSharedWeixinHandlerResponseNotification object:resp];
    }
}

@end
