//
//  SFMapAppFactory.h
//  SFMapApp
//
//  Created by yangzexin on 11/20/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMapApp.h"
#import "SFBaiduMapApp.h"

@interface SFMapAppFactory : NSObject

+ (id<SFMapApp>)autoNaviMap;
+ (id<SFMapApp>)baiduMap;
+ (id<SFMapApp>)googleMap;
+ (id<SFMapApp>)systemMap;

@end
