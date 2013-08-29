//
//  Api.m
//  ChaseMe
//
//  Created by irem korkmaz on 6/8/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import "Api.h"
#import "SBJson.h"

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

- (id)apiCall: (NSString *)url
{
    //url = [Base_Url stringByAppendingString:url];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    NSURLResponse *resp = nil;
    NSError *err = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &err];
    NSString * theString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSMutableDictionary *returnDict = [[jsonParser objectWithString:theString] mutableCopy];
    return returnDict;
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

-(id)addFriend:(NSString *)userId
{
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequests"];
    [query whereKey:@"sender" equalTo:[[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"]];
    [query whereKey:@"receiver" equalTo:userId];
    
    NSMutableArray *objects1 = [[query findObjects] mutableCopy];
    if([objects1 count] == 0)
    {
        PFQuery *query2 = [PFQuery queryWithClassName:@"FriendRequests"];
        [query2 whereKey:@"receiver" equalTo:[[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"]];
        [query2 whereKey:@"sender" equalTo:userId];
        NSMutableArray *objects2 = [[query2 findObjects] mutableCopy];
        if([objects2 count] == 0)
        {
            PFUser *currentUser = [PFUser currentUser];
            NSString *currentUserName = [currentUser valueForKey:@"Name"];
            NSString *currentUserPicture = [currentUser valueForKey:@"picture"];
            NSString * url = [NSString stringWithFormat:@"http://graph.facebook.com/%@?fields=id,picture,first_name,last_name" , userId];
            NSMutableDictionary *returnDict = [self apiCall:url];
            PFObject *incidentObject = [PFObject objectWithClassName:@"FriendRequests"];
            [incidentObject setObject:[[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"] forKey:@"sender"];
            [incidentObject setObject:userId forKey:@"receiver"];
            [incidentObject setObject:[NSNumber numberWithFloat:0] forKey:@"isFriends"];
            [incidentObject setObject:[returnDict valueForKey:@"first_name"] forKey:@"firstName"];
            [incidentObject setObject:[returnDict valueForKey:@"last_name"] forKey:@"lastName"];
            [incidentObject setObject:[[[returnDict valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"] forKey:@"picture"];
            [incidentObject setObject:currentUserName forKey:@"senderName"];
            [incidentObject setObject:currentUserPicture forKey:@"senderPicture"];
            [incidentObject save];
        }
    }
    
    return nil;
}

-(id)getPictureURL:(NSString *)userId
{
    NSString * url = [NSString stringWithFormat:@"http://graph.facebook.com/%@?fields=id,picture,first_name,last_name" , userId];
    NSMutableDictionary *returnDict = [self apiCall:url];
    NSString *imageURL = [[[returnDict valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
    return imageURL;
}

-(id)searchPlace:(NSMutableDictionary *)searchParams
{
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&key=%@&sensor=true&location=%@,%@&radius=%d" , [[searchParams valueForKey:@"placeName"] stringByReplacingOccurrencesOfString:@" " withString:@"+"] , GooglePlacesApiKey , [searchParams valueForKey:@"latitude"] , [searchParams valueForKey:@"longitude"] , 50000];
    NSMutableDictionary *dict = [self apiCall:url];
    return [dict valueForKey:@"results"];
}

-(id)createGroup:(NSMutableDictionary *)params
{
    NSMutableArray *addedFriends = [[NSMutableArray alloc] init];
    NSString *currentUserId = [[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"];
    for(int i = 0 ; i < [[params objectForKey:@"indexPaths"] count] ; i++)
    {
        PFQuery *userQuery = [PFUser query];
        
        PFObject *friendObject = [[params valueForKey:@"friends"] objectAtIndex:((NSIndexPath *)[[params objectForKey:@"indexPaths"] objectAtIndex:i]).row];
        if([currentUserId isEqualToString:[friendObject valueForKey:@"receiver"]])
        {
            [addedFriends addObject:[friendObject valueForKey:@"sender"]];
            [userQuery whereKey:@"facebookId" equalTo:[friendObject valueForKey:@"sender"]];
        }
        else
        {
            [addedFriends addObject:[friendObject valueForKey:@"receiver"]];
            [userQuery whereKey:@"facebookId" equalTo:[friendObject valueForKey:@"receiver"]];
        }
        
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects , NSError *error) {
            if([objects count] > 0)
            {
                PFObject *object = [objects objectAtIndex:0];
                PFPush *push = [[PFPush alloc] init];
                [push setChannel:[object valueForKey:@"deviceToken"]];
                [push setMessage:@"I have added you to a new group, come join me!"];
                [push sendPushInBackground];
            }
        }];
        
    }
    [addedFriends addObject:currentUserId];
    PFObject *incidentObject = [PFObject objectWithClassName:@"Groups"];
    [incidentObject setObject:addedFriends forKey:@"people"];
    [incidentObject setObject:[NSNumber numberWithInt:1] forKey:@"isActive"];
    [incidentObject setObject:[params valueForKey:@"latitude"] forKey:@"latitude"];
    [incidentObject setObject:[params valueForKey:@"longitude"] forKey:@"longitude"];
    [incidentObject setObject:[params valueForKey:@"placeName"] forKey:@"placeName"];
    [incidentObject save];
    return nil;
}

@end