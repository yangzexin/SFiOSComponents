//
//  SFMapAppFactory.m
//  SFMapApp
//
//  Created by yangzexin on 11/20/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFMapAppFactory.h"
#import "SFAutoNaviMapApp.h"
#import "SFGoogleMapApp.h"
#import "SFSystemMapApp.h"

@implementation SFMapAppFactory

+ (id<SFMapApp>)autoNaviMap
{
    return [[SFAutoNaviMapApp new] autorelease];
}

+ (id<SFMapApp>)baiduMap
{
    return [[[SFBaiduMapApp alloc] init] autorelease];
}

+ (id<SFMapApp>)googleMap
{
    return [[SFGoogleMapApp new] autorelease];
}

+ (id<SFMapApp>)systemMap
{
    return [[SFSystemMapApp new] autorelease];
}

@end
