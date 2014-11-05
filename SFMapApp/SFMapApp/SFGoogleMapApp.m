//
//  GoogleMapApp.m
//  SimpleFramework
//
//  Created by yangzexin on 8/28/13.
//  Copyright (c) 2013 SimpleFramework. All rights reserved.
//

#import "SFGoogleMapApp.h"
#import "SFMapDirectionRequest.h"
#import <CoreLocation/CoreLocation.h>

@implementation SFGoogleMapApp

- (NSString *)name
{
    return @"谷歌地图";
}

- (BOOL)available
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]];
}

- (void)directionWithRequest:(SFMapDirectionRequest *)request
{
    NSString *URLString = nil;
    if(request.usingUserLocationAsFromLocationCoordinate){
        URLString = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%f,%f&directionsmode=driving",
                     request.toLocationCoordinate.latitude, request.toLocationCoordinate.longitude];
    }else{
        URLString = [NSString stringWithFormat:@"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=driving",
                     request.fromLocationCoordinate.latitude, request.fromLocationCoordinate.longitude,
                     request.toLocationCoordinate.latitude, request.toLocationCoordinate.longitude];
    }
    URLString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
}

@end
