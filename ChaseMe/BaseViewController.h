//
//  BaseViewController.h
//  ChaseMe
//
//  Created by irem korkmaz on 6/7/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "MenuViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import <CoreLocation/CoreLocation.h>
#import "Api.h"
#import <Parse/Parse.h>
#import "SIAlertView.h"

@interface BaseViewController : UIViewController <SidebarViewControllerDelegate , CLLocationManagerDelegate>

@property (nonatomic , strong) CLLocation *currentLocation;
@property (nonatomic , strong) NSMutableArray *myLocations;
@property (nonatomic , strong) CLLocationManager *locationManager;

@end
