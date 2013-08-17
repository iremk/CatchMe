//
//  Api.h
//  ChaseMe
//
//  Created by irem korkmaz on 6/8/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface Api : NSObject <CLLocationManagerDelegate>

@property (nonatomic , retain) NSMutableArray *locationsArray;

+ (id)sharedInstance;
-(id)getCurrentLocation;
-(id)convertLocationsToString:(NSMutableArray *)locations;
-(id)addFriend:(NSString *)userId;
-(id)searchPlace:(NSMutableDictionary *)searchParams;
-(id)createGroup:(NSMutableDictionary *)params;
-(id)getPictureURL:(NSString *)userId;

@end
