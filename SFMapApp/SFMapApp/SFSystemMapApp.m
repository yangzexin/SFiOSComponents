//
//  SystemMap.m
//  SimpleFramework
//
//  Created by yangzexin on 8/28/13.
//  Copyright (c) 2013 SimpleFramework. All rights reserved.
//

#import "SFSystemMapApp.h"
#import <MapKit/MapKit.h>
#import "SFMapDirectionRequest.h"
#import <CoreLocation/CoreLocation.h>

@implementation SFSystemMapApp

- (NSString *)name
{
    return @"系统地图";
}

- (BOOL)available
{
    return YES;
}

- (void)directionWithRequest:(SFMapDirectionRequest *)request
{
    if([[UIDevice currentDevice].systemVersion floatValue] < 6.0f){
        CLLocationCoordinate2D fromLocation = request.fromLocationCoordinate;
        CLLocationCoordinate2D toLocation = request.toLocationCoordinate;
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%.6f,%.6f",
                                           fromLocation.latitude, fromLocation.longitude, toLocation.latitude, toLocation.longitude]];
        if(request.usingUserLocationAsFromLocationCoordinate){
            url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@&daddr=%.6f,%.6f",
                                        [[[self class] currentLocationStringForCurrentLanguage] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], toLocation.latitude, toLocation.longitude]];
        }
        [[UIApplication sharedApplication] openURL:url];
    }else{
        MKMapItem *currentLocation = nil;
        if(request.usingUserLocationAsFromLocationCoordinate){
            currentLocation = [MKMapItem mapItemForCurrentLocation];
        }else{
            currentLocation = [[[MKMapItem alloc] initWithPlacemark:[[[MKPlacemark alloc] initWithCoordinate:request.fromLocationCoordinate addressDictionary:nil] autorelease]] autorelease];
        }
        MKMapItem *toLocation = [[[MKMapItem alloc] initWithPlacemark:[[[MKPlacemark alloc] initWithCoordinate:request.toLocationCoordinate addressDictionary:nil] autorelease]] autorelease];
        
        toLocation.name = request.toAddress;
        toLocation.phoneNumber = request.toPhoneNumber;
        
        [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                       launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                                                 forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
    }
}

+ (NSString *)currentLocationStringForCurrentLanguage
{
    
    NSDictionary *localizedStringDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                               @"Huidige locatie", @"nl",
                                               @"Current Location", @"en",
                                               @"Lieu actuel", @"fr",
                                               @"Aktueller Ort", @"de",
                                               @"Posizione attuale", @"it",
                                               @"現在地", @"ja",
                                               @"Ubicación actual", @"es",
                                               @"الموقع الحالي", @"ar",
                                               @"Ubicació actual", @"ca",
                                               @"Současná poloha", @"cs",
                                               @"Aktuel lokalitet", @"da",
                                               @"Τρέχουσα τοποθεσία", @"el",
                                               @"Current Location", @"en-GB",
                                               @"Nykyinen sijainti", @"fi",
                                               @"מיקום נוכחי", @"he",
                                               @"Trenutna lokacija", @"hr",
                                               @"Jelenlegi helyszín", @"hu",
                                               @"Lokasi Sekarang", @"id",
                                               @"현재 위치", @"ko",
                                               @"Lokasi Semasa", @"ms",
                                               @"Nåværende plassering", @"no",
                                               @"Bieżące położenie", @"pl",
                                               @"Localização Atual", @"pt",
                                               @"Localização actual", @"pt-PT",
                                               @"Loc actual", @"ro",
                                               @"Текущее размещение", @"ru",
                                               @"Aktuálna poloha", @"sk",
                                               @"Nuvarande plats", @"sv",
                                               @"ที่ตั้งปัจจุบัน", @"th",
                                               @"Şu Anki Yer", @"tr",
                                               @"Поточне місце", @"uk",
                                               @"Vị trí Hiện tại", @"vi",
                                               @"当前位置", @"zh-CN",
                                               @"目前位置", @"zh-TW",
                                               @"当前位置", @"zh-Hans",
                                               @"目前位置", @"zh-Hant",
                                               nil];
    
    NSString *localizedString;
    NSString *currentLanguageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    if ([localizedStringDictionary valueForKey:currentLanguageCode]) {
        localizedString = [NSString stringWithString:[localizedStringDictionary valueForKey:currentLanguageCode]];
    } else {
        localizedString = [NSString stringWithString:[localizedStringDictionary valueForKey:@"en"]];
    }
    
    [localizedStringDictionary release];
    return localizedString;
}

@end
