//
//  SFQQWeiboShare.h
//  SFThirdPartyQQ
//
//  Created by yangzexin on 6/4/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFQQWeiboShare : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) NSString *ip;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@end
