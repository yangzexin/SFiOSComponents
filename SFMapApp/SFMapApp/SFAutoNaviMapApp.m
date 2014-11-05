//
//  GaoDeMapApp.m
//  SimpleFramework
//
//  Created by yangzexin on 8/28/13.
//  Copyright (c) 2013 SimpleFramework. All rights reserved.
//

#import "SFAutoNaviMapApp.h"
#import "SFMapDirectionRequest.h"
#import <CoreLocation/CoreLocation.h>

@implementation SFAutoNaviMapApp

- (BOOL)available
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]];
}

- (NSString *)name
{
    return @"高德地图";
}

- (void)directionWithRequest:(SFMapDirectionRequest *)request
{
    CLLocationCoordinate2D toLocation = request.toLocationCoordinate;
    CLLocationCoordinate2D fromLocation = request.fromLocationCoordinate;
    NSString *URLString = nil;
    if(request.usingUserLocationAsFromLocationCoordinate){
        URLString = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&poiname=%@&lat=%f&lon=%f&dev=0&style=2",
                     [request.sourceApplicationName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                     request.sourceApplicationCallbackScheme,
                     [request.toAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], toLocation.latitude, toLocation.longitude];
    }else{
        URLString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&backScheme=%@&&slat=%f&slon=%f&sname=%@&dlat=%f&dlon=%f&dname=%@&dev=0&m=0&t=0",
                     [request.sourceApplicationName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                     request.sourceApplicationCallbackScheme,
                     fromLocation.latitude, fromLocation.longitude, [request.fromAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                     toLocation.latitude, toLocation.longitude, [request.toAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
}

@end
