//
//  BaiduMapApp.m
//  SimpleFramework
//
//  Created by yangzexin on 8/28/13.
//  Copyright (c) 2013 SimpleFramework. All rights reserved.
//

#import "SFBaiduMapApp.h"
#import "SFMapDirectionRequest.h"
#import <CoreLocation/CoreLocation.h>

@interface SFBaiduMapAppBlockedSupporter ()

@property (nonatomic, copy) NSString *(^base64StringToUTF8StringHandler)(NSString *base64String);
@property (nonatomic, copy) NSDictionary *(^JSONStringToDictionaryHandler)(NSString *JSONString);

@end

@implementation SFBaiduMapAppBlockedSupporter

- (void)dealloc
{
    self.base64StringToUTF8StringHandler = nil;
    self.JSONStringToDictionaryHandler = nil;
    [super dealloc];
}

+ (id)supporterWithBase64StringToUTF8StringHandler:(NSString *(^)(NSString *base64String))base64StringToUTF8StringHandler
                     JSONStringToDictionaryHandler:(NSDictionary *(^)(NSString *JSONString))JSONStringToDictionaryHandler
{
    SFBaiduMapAppBlockedSupporter *supporter = [[SFBaiduMapAppBlockedSupporter new] autorelease];
    supporter.base64StringToUTF8StringHandler = base64StringToUTF8StringHandler;
    supporter.JSONStringToDictionaryHandler = JSONStringToDictionaryHandler;
    return supporter;
}

- (NSString *)UTF8StringFromBase64String:(NSString *)base64String
{
    return self.base64StringToUTF8StringHandler(base64String);
}

- (NSDictionary *)dictionaryFromJSONString:(NSString *)JSONString
{
    return self.JSONStringToDictionaryHandler(JSONString);
}

@end

@interface SFBaiduMapAppConvertCoordinateRequest ()

@property (nonatomic, copy) void(^completion)(CLLocationCoordinate2D convertedCoordinate);

@end

@implementation SFBaiduMapAppConvertCoordinateRequest

@synthesize requestDidFinish;

- (void)dealloc
{
    [self cancel];
    self.requestDidFinish = nil;
    self.completion = nil;
    self.supporter = nil;
    [super dealloc];
}

- (id)objectWithJSONString:(NSString *)JSONString
{
    return [self.supporter dictionaryFromJSONString:JSONString];
}

- (NSString *)stringFromBase64String:(NSString *)base64String
{
    return [self.supporter UTF8StringFromBase64String:base64String];
}

- (void)requestWithCoordinate:(CLLocationCoordinate2D)coordinate completion:(void(^)(CLLocationCoordinate2D convertedCoordinate))completion
{
    self.completion = completion;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger from = 0;
        NSInteger to = 4;
        
        switch (_type) {
            case SFBaiduMapAppConvertTypeMapNormal:
                from = 0;
                to = 4;
                break;
            case SFBaiduMapAppConvertTypeGPS:
                from = 2;
                to = 4;
                break;
            case SFBaiduMapAppConvertTypeLocationOffset:
                from = 0;
                to = 2;
                break;
                
            default:
                break;
        }
        
        NSString *urlString = [NSString stringWithFormat:@"http://api.map.baidu.com/ag/coord/convert?from=%ld&to=%ld&x=%f&y=%f", (long)from, (long)to, coordinate.longitude, coordinate.latitude];
        NSString *covertedCoordinateString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *responseDictionary = [self objectWithJSONString:covertedCoordinateString];
        
        NSString *latitude = [self stringFromBase64String:[responseDictionary objectForKey:@"y"]];
        NSString *longitude = [self stringFromBase64String:[responseDictionary objectForKey:@"x"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.completion){
                self.completion(CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]));
            }
        });
        dispatch_async(dispatch_get_main_queue(),  ^{
            if(self.requestDidFinish){
                self.requestDidFinish();
            }
        });
    });
}

- (void)cancel
{
    self.completion = nil;
    self.requestDidFinish = nil;
}

+ (id)requestWithSupporter:(id<SFBaiduMapAppSupporter>)supporter
{
    SFBaiduMapAppConvertCoordinateRequest *request = [[SFBaiduMapAppConvertCoordinateRequest new] autorelease];
    request.supporter = supporter;
    return request;
}

@end

@interface SFBaiduCoordinateConverter : NSObject <MapDirectionRequestControllable>

@property (nonatomic, retain) SFBaiduMapAppConvertCoordinateRequest *convertSrcLocationRequest;
@property (nonatomic, retain) SFBaiduMapAppConvertCoordinateRequest *convertDesLocationRequest;
@property (nonatomic, retain) id<SFBaiduMapAppSupporter> supporter;

@property (nonatomic, assign) CLLocationCoordinate2D convertedSrcCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D convertedDesCoordinate;

@property (nonatomic, copy) void(^completion)(CLLocationCoordinate2D srcCoordinate, CLLocationCoordinate2D desCoordinate);

@end

@implementation SFBaiduCoordinateConverter

@synthesize requestDidFinish;

- (void)dealloc
{
    [_convertSrcLocationRequest cancel]; [_convertSrcLocationRequest release];
    [_convertDesLocationRequest cancel]; [_convertDesLocationRequest release];
    [_supporter release];
    Block_release(_completion); _completion = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.convertedSrcCoordinate = kCLLocationCoordinate2DInvalid;
    self.convertedDesCoordinate = kCLLocationCoordinate2DInvalid;
    
    return self;
}

- (void)convertWithSrcCoordinate:(CLLocationCoordinate2D)srcCoordinate
                   desCoordinate:(CLLocationCoordinate2D)desCoordinate
                      completion:(void(^)(CLLocationCoordinate2D, CLLocationCoordinate2D))completion
{
    self.completion = completion;
    
    self.convertSrcLocationRequest = [SFBaiduMapAppConvertCoordinateRequest requestWithSupporter:self.supporter];
    _convertSrcLocationRequest.type = SFBaiduMapAppConvertTypeGPS;
    __block typeof(self) bself = self;
    [self.convertSrcLocationRequest requestWithCoordinate:srcCoordinate completion:^(CLLocationCoordinate2D convertedCoordinate) {
        bself.convertedSrcCoordinate = convertedCoordinate;
        [bself _locationConverted];
    }];
    
    self.convertDesLocationRequest = [SFBaiduMapAppConvertCoordinateRequest requestWithSupporter:self.supporter];
    _convertDesLocationRequest.type = SFBaiduMapAppConvertTypeGPS;
    [_convertDesLocationRequest requestWithCoordinate:desCoordinate completion:^(CLLocationCoordinate2D convertedCoordinate) {
        bself.convertedDesCoordinate = convertedCoordinate;
        [bself _locationConverted];
    }];
}

- (void)cancel
{
    [_convertSrcLocationRequest cancel];
    [_convertDesLocationRequest cancel];
    self.completion = nil;
}

- (void)_locationConverted
{
    if (CLLocationCoordinate2DIsValid(_convertedSrcCoordinate) && CLLocationCoordinate2DIsValid(_convertedDesCoordinate)) {
        if (requestDidFinish) {
            requestDidFinish();
            self.requestDidFinish = nil;
        }
        if (_completion) {
            _completion(_convertedSrcCoordinate, _convertedDesCoordinate);
            self.completion = nil;
        }
    }
}

@end

@interface SFBaiduMapApp ()

@end

@implementation SFBaiduMapApp

- (NSString *)name
{
    return @"百度地图";
}

- (BOOL)available
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]];
}

- (void)directionWithRequest:(SFMapDirectionRequest *)request
{
    NSString *URLString = [NSString stringWithFormat:@"baidumap://map/direction?coord_type=gcj02&origin=%f,%f&destination=%f,%f&mode=driving",
                           request.fromLocationCoordinate.latitude, request.fromLocationCoordinate.longitude,
                           request.toLocationCoordinate.latitude, request.toLocationCoordinate.longitude
                           ];
    NSURL *url = [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
}

@end
