//
//  SFWeixinRequestCatcher.m
//  SFShareKit
//
//  Created by yangzexin on 1/14/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFWeixinRequestCatcher.h"

#import "SFSharedWeixinHandler.h"

#import "WXApi.h"

@interface SFWeixinRequestCatcher () <WXApiDelegate>

@end

@implementation SFWeixinRequestCatcher

+ (void)initWithAppId:(NSString *)appId
{
    [WXApi registerApp:appId];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_requestNotification:) name:SFSharedWeixinHandlerRequestNotification object:nil];
    
    return self;
}

- (void)_requestNotification:(NSNotification *)note
{
    [self onReq:note.object];
}

- (void)onReq:(WXMediaMessage*)temp
{
    if ([_delegate respondsToSelector:@selector(weixinRequestCatcher:didCatchMessage:)]) {
        [_delegate weixinRequestCatcher:self didCatchMessage:temp];
    }
}

@end
