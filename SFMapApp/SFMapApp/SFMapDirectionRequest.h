//
//  MapDirectionRequest.h
//  SimpleFramework
//
//  Created by yangzexin on 8/28/13.
//  Copyright (c) 2013 SimpleFramework. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol MapDirectionRequestControllable;

@interface SFMapDirectionRequest : NSObject

@property (nonatomic, copy) NSString *sourceApplicationName;

/**
 地图App会调用这个scheme回调App
 */
@property (nonatomic, copy) NSString *sourceApplicationCallbackScheme;

/**
 起始地址
 */
@property (nonatomic, copy) NSString *fromAddress;

/**
 目标地址
 */
@property (nonatomic, copy) NSString *toAddress;

/**
 起始地址电话号码
 */
@property (nonatomic, copy) NSString *fromPhoneNumber;

/**
 目标地址电话号码
 */
@property (nonatomic, copy) NSString *toPhoneNumber;

/**
 起始城市名
 */
@property (nonatomic, copy) NSString *fromCityName;

/**
 目标城市名
 */
@property (nonatomic, copy) NSString *toCityName;

/**
 起始位置坐标
 */
@property (nonatomic, assign) CLLocationCoordinate2D fromLocationCoordinate;

/**
 目标位置坐标
 */
@property (nonatomic, assign) CLLocationCoordinate2D toLocationCoordinate;

/**
 是否使用用户当前位置作为起始位置
 */
@property (nonatomic, assign) BOOL usingUserLocationAsFromLocationCoordinate;

@property (nonatomic, retain) id<MapDirectionRequestControllable> controllable;

@end

@protocol MapDirectionRequestControllable <NSObject>

@property (nonatomic, copy) void(^requestDidFinish)();
- (void)cancel;

@end
