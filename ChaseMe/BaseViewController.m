//
//  BaseViewController.m
//  ChaseMe
//
//  Created by irem korkmaz on 6/7/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import "BaseViewController.h"
#import "MapViewController.h"
#import "ConnectionsViewController.h"
#import "SettingsViewController.h"

@interface BaseViewController ()
{
}

@end

@implementation BaseViewController
@synthesize currentLocation;
@synthesize myLocations;
@synthesize locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    myLocations = [[NSMutableArray alloc] init];
	// Do any additional setup after loading the view.
    ((MenuViewController *)self.sidePanelController.leftPanel).sidebarDelegate = self;
    [[SIAlertView appearance] setMessageFont:[UIFont fontWithName:@"GillSans-Light" size:12.0]];
    [[SIAlertView appearance] setTitleColor:[UIColor whiteColor]];
    [[SIAlertView appearance] setMessageColor:[UIColor lightGrayColor]];
    [[SIAlertView appearance] setCornerRadius:12];
    [[SIAlertView appearance] setShadowRadius:20];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = 100;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationManager.delegate = self;
    currentLocation = [locationManager location];
    [locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    
    PFUser *currentUser = [PFUser currentUser];
    if(currentUser)
    {
        [currentUser setValue:[NSNumber numberWithFloat:newLocation.coordinate.latitude] forKey:@"latitude"];
        [currentUser setValue:[NSNumber numberWithFloat:newLocation.coordinate.longitude] forKey:@"longitude"];
        [currentUser saveInBackground];
    }
    
    [myLocations addObject:newLocation];
    if([myLocations count] == 6)
    {
        [myLocations removeObjectAtIndex:0];
        if([self isKindOfClass:[MapViewController class]])
            [[NSNotificationCenter defaultCenter] postNotificationName:MyLocationsNotification object:nil userInfo:nil];

        PFUser *user = [PFUser currentUser];
        [user setObject:[[Api sharedInstance] convertLocationsToString:myLocations] forKey:@"locations"];
        [user saveInBackground];
    }
}

- (void)sidebarViewController:(MenuViewController *)sidebarViewController didSelectObject:(NSObject *)object atIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0)
    {
        self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:(MapViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"mapViewController"]];
    }
    else if(indexPath.row == 1)
    {
        self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:(ConnectionsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"connectionsViewController"]];
    }
    else if(indexPath.row == 2)
    {
        self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:(SettingsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"settingsViewController"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
