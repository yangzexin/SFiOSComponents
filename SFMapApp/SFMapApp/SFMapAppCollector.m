//
//  MapAppManager.m
//  SimpleFramework
//
//  Created by yangzexin on 8/28/13.
//  Copyright (c) 2013 SimpleFramework. All rights reserved.
//

#import "SFMapAppCollector.h"
#import "SFSystemMapApp.h"
#import "SFAutoNaviMapApp.h"
#import "SFBaiduMapApp.h"
#import "SFGoogleMapApp.h"

@interface SFMapAppCollector ()

@property (nonatomic, retain) NSMutableArray *apps;

@end

@implementation SFMapAppCollector

- (void)dealloc
{
    [_apps release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.apps = [NSMutableArray array];
    
    return self;
}

- (void)addApp:(id<SFMapApp>)app
{
    if([self.apps indexOfObject:app] == NSNotFound){
        [self.apps addObject:app];
    }
}

- (void)removeApp:(id<SFMapApp>)app
{
    [self.apps removeObject:app];
}

- (NSArray *)availableApps
{
    NSMutableArray *existApps = [NSMutableArray array];
    for(id<SFMapApp> app in self.apps){
        if([app available]){
            [existApps addObject:app];
        }
    }
    return existApps;
}

- (NSArray *)allApps
{
    return [NSArray arrayWithArray:self.apps];
}

@end
