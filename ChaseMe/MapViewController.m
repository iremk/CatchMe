//
//  ViewController.m
//  ChaseMe
//
//  Created by irem korkmaz on 6/7/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()
{
    PFLogInViewController *logInController;
    GMSMutablePath *path;
}

@end

@implementation MapViewController
@synthesize mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    CLLocation *location = self.currentLocation;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                            longitude:location.coordinate.longitude
                                                                 zoom:14];
    [mapView setCamera:camera];
    mapView.myLocationEnabled = YES;
    mapView.delegate = self;
    if(![PFUser currentUser])
        [self logmein];
    path = [GMSMutablePath path];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(drawPolylineToMap:)
     name:MyLocationsNotification
     object:nil];
}

- (void)mapView:(GMSMapView *)inMapView
didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Bilgi" andMessage:@"Gitmek istediğiniz yeri mi seçtiniz?"];
     [alertView addButtonWithTitle:@"Hayır"
     type:SIAlertViewButtonTypeDestructive
     handler:^(SIAlertView *alertView) {
     NSLog(@"Cancel Clicked");
     }];
     [alertView addButtonWithTitle:@"Evet"
     type:SIAlertViewButtonTypeDefault
     handler:^(SIAlertView *alertView) {
         CLLocationCoordinate2D position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
         GMSMarker *marker = [GMSMarker markerWithPosition:position];
         marker.title = @"Varış Noktası";
         marker.map = inMapView;
     }];
    [alertView show];
}

-(void)drawPolylineToMap:(NSNotification*)notification
{
    GMSPolyline *polyline = [[GMSPolyline alloc] init];
    [path removeAllCoordinates];
    for(int i = 0 ; i < 5 ; i++)
    {
        [path addCoordinate:((CLLocation *)[self.myLocations objectAtIndex:i]).coordinate];
    }
    polyline.path = path;
    polyline.strokeColor = [UIColor redColor];
    polyline.strokeWidth = 2.f;
    polyline.map = mapView;
}

-(void)logmein
{
    logInController = [[PFLogInViewController alloc] init];
    logInController.delegate = self;
    logInController.fields = PFLogInFieldsFacebook;
    logInController.logInView.logo = (UIView *)[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"parseLogo.png"]];
    [logInController.logInView.dismissButton setHidden:YES];
    [logInController.logInView setBackgroundColor:[UIColor colorWithRed:38.0/255.0 green:17.0/255.0 blue:25.0/225.0 alpha:1.0]];
    [self presentViewController:logInController animated:YES completion:nil];
}

- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
