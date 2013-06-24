//
//  Api.m
//  ChaseMe
//
//  Created by irem korkmaz on 6/8/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import "Api.h"

@implementation Api
@synthesize locationsArray;

+ (id)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


-(id)getCurrentLocation
{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    locationManager.delegate = self;
    CLLocation *location = [locationManager location];
    return location;
}

-(id)convertLocationsToString:(NSMutableArray *)locations
{
    NSString *returnStr = @"";
    for(int i = 0 ; i < [locations count]; i++)
    {
        CLLocation *location = (CLLocation *)[locations objectAtIndex:i];
        NSString *locationStr = [NSString stringWithFormat:@"%lf-%lf" , location.coordinate.longitude,location.coordinate.latitude];
        returnStr = [returnStr stringByAppendingString:locationStr];
        if(i != [locations count]-1)
            returnStr = [returnStr stringByAppendingString:@";"];
    }
    return returnStr;
}

-(id)becomeFriends:(NSString *)facebookUserId
{
#warning directive - become friends hemen yazılmalı
    //become friends kodu
    return nil;
}

@end