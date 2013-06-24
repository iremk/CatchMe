//
//  Api.h
//  ChaseMe
//
//  Created by irem korkmaz on 6/8/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Api : NSObject <CLLocationManagerDelegate>

@property (nonatomic , retain) NSMutableArray *locationsArray;

+ (id)sharedInstance;
-(id)getCurrentLocation;
-(id)convertLocationsToString:(NSMutableArray *)locations;
-(id)becomeFriends:(NSString *)facebookUserId;

@end
