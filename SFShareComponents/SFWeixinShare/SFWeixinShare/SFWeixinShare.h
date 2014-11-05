//
//  SFWeixinShare.h
//  SFWeixinShare
//
//  Created by yangzexin on 5/23/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SFWeixinShareType){
    SFWeixinShareTypeFriend,
    SFWeixinShareTypeTimeline,
};

OBJC_EXPORT NSInteger const SFWeixinShareErrorCodeNotInstalled;
OBJC_EXPORT NSInteger const SFWeixinShareErrorCodeSendRequestFailed;
OBJC_EXPORT NSInteger const SFWeixinShareErrorCodeUserCancelled;

@interface SFWeixinShare : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *extInfo;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) SFWeixinShareType type;
@property (nonatomic, assign) BOOL redirectToUrl;

@end
