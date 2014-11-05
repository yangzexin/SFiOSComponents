//
//  BaiduMapApp.h
//  SimpleFramework
//
//  Created by yangzexin on 8/28/13.
//  Copyright (c) 2013 SimpleFramework. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMapApp.h"

@protocol SFBaiduMapAppSupporter <NSObject>

- (NSString *)UTF8StringFromBase64String:(NSString *)base64String;
- (NSDictionary *)dictionaryFromJSONString:(NSString *)JSONString;

@end

@interface SFBaiduMapAppBlockedSupporter : NSObject <SFBaiduMapAppSupporter>

+ (id)supporterWithBase64StringToUTF8StringHandler:(NSString *(^)(NSString *base64String))base64StringToUTF8StringHandler
                     JSONStringToDictionaryHandler:(NSDictionary *(^)(NSString *JSONString))JSONStringToDictionaryHandler;

@end

typedef NS_ENUM(NSUInteger, SFBaiduMapAppConvertType) {
    SFBaiduMapAppConvertTypeMapNormal,
    SFBaiduMapAppConvertTypeGPS,
    SFBaiduMapAppConvertTypeLocationOffset,
};

@interface SFBaiduMapAppConvertCoordinateRequest : NSObject <MapDirectionRequestControllable>

@property (nonatomic, retain) id<SFBaiduMapAppSupporter> supporter;
@property (nonatomic, assign) SFBaiduMapAppConvertType type;

- (void)requestWithCoordinate:(CLLocationCoordinate2D)coordinate completion:(void(^)(CLLocationCoordinate2D convertedCoordinate))completion;

@end

@interface SFBaiduMapApp : NSObject <SFMapApp>

@end
