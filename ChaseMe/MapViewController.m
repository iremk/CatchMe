//
//  ViewController.m
//  ChaseMe
//
//  Created by irem korkmaz on 6/7/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import "MapViewController.h"
#import "CreateViewController.h"

@interface MapViewController ()
{
    PFLogInViewController *logInController;
    GMSMutablePath *path;
    
    NSMutableArray *groupsArray;
}

@end

@implementation MapViewController
@synthesize mapView;
@synthesize centralizeButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    groupsArray = [[NSMutableArray alloc] init];
    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status == kCLAuthorizationStatusAuthorized)
    {
        NSLog(@"no problem man");
    }
    else if(status == kCLAuthorizationStatusDenied)
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Info" andMessage:@"You need to allow Location Services for Pinite from Settings > Privacy > Location Services > Pinite to use Pinite"];
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:^(SIAlertView *alertView) {
                                  NSLog(@"Cancel Clicked");
                              }];
        [alertView show];
    }
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
    
    if([PFUser currentUser])
        [self checkGroup];

    NSString *imageName0 = @"tutorialChar4.png";
    NSString *imageName1 = @"openingTutorial4.png";
    NSString *imageName2 = @"createGroupTutorial4.png";
    NSString *imageName3 = @"connectionsTutorial4.png";
    NSString *imageName4 = @"settingsTutorial4.png";
    if(self.view.frame.size.height > 960)
    {
        imageName0 = @"tutorialChar5.png";
        imageName1 = @"openingTutorial5.png";
        imageName2 = @"createGroupTutorial5.png";
        imageName3 = @"connectionsTutorial5.png";
        imageName4 = @"settingsTutorial5.png";
    }
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(![userDefaults boolForKey:@"tutorialShown"])
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"tutorialShown"];
        [userDefaults synchronize];
        MYIntroductionPanel *panel0 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:imageName0] description:@""];
        
        
        MYIntroductionPanel *panel = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:imageName1] description:@""];
        
        //You may also add in a title for each panel
        MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:imageName2]   description:@""];
        MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:imageName3]   description:@""];
        MYIntroductionPanel *panel4 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:imageName4]   description:@""];
        
        /*A more customized version*/
        MYIntroductionView *introductionView = [[MYIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) headerText:@"Tutorial" panels:@[panel0,panel, panel2, panel3,panel4] languageDirection:MYLanguageDirectionLeftToRight];
    //    [introductionView setBackgroundImage:[UIImage imageNamed:@"SampleBackground"]];
        
        
        //Set delegate to self for callbacks (optional)
        introductionView.delegate = self;
        
        //STEP 3: Show introduction view
        [introductionView showInView:self.view];
    }
}

-(void)introductionDidFinishWithType:(MYFinishType)finishType{
    if (finishType == MYFinishTypeSkipButton) {
        NSLog(@"Did Finish Introduction By Skipping It");
    }
    else if (finishType == MYFinishTypeSwipeOut){
        NSLog(@"Did Finish Introduction By Swiping Out");
    }
    //One might consider making the introductionview a class variable and releasing it here.
    // I didn't do this to keep things simple for the sake of example.
}

-(void)introductionDidChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    NSLog(@"%@ \nPanelIndex: %d", panel.Description, panelIndex);
}

-(IBAction)centralize:(id)sender
{
    CLLocation *location = self.currentLocation;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                            longitude:location.coordinate.longitude
                                                                 zoom:14];
    [mapView setCamera:camera];
}

-(UIView *)mapView:(GMSMapView *)inMapView markerInfoWindow:(GMSMarker *)marker
{
    UIView *markerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 60)];
    [markerView setBackgroundColor:[UIColor colorWithRed:64.0/255.0 green:27.0/255.0 blue:3.0/255.0 alpha:1.0]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 32)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont fontWithName:@"GillSans-Light" size:16.0]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:marker.title];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    UILabel *titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 34, 120, 24)];
    [titleLabel2 setBackgroundColor:[UIColor clearColor]];
    titleLabel2.numberOfLines = 2;
    [titleLabel2 setFont:[UIFont fontWithName:@"GillSans-Light" size:10.0]];
    [titleLabel2 setTextColor:[UIColor whiteColor]];
    [titleLabel2 setText:[NSString stringWithFormat:@"Last seen : %@" , marker.snippet]];
    [titleLabel2 setTextAlignment:NSTextAlignmentCenter];
    
    [markerView addSubview:titleLabel];
    [markerView addSubview:titleLabel2];
    markerView.layer.cornerRadius = 8;
    
    GMSPolyline *polyline = [[GMSPolyline alloc] init];
    NSString *locations = marker.userData;
    NSArray *locationsArray = [locations componentsSeparatedByString:@";"];
    for(int l = 0 ; l < [locationsArray count] ; l++)
    {
        NSArray *coordinateArray = [[locationsArray objectAtIndex:l] componentsSeparatedByString:@"-"];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[[coordinateArray objectAtIndex:1] floatValue] longitude:[[coordinateArray objectAtIndex:0] floatValue]];
        [path addCoordinate:location.coordinate];
    }
    polyline.path = path;
    polyline.strokeColor = [UIColor redColor];
    polyline.strokeWidth = 2.f;
    polyline.map = mapView;
    
    return markerView;
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
    for(id obj in logInController.view.subviews)
    {
        if([obj isKindOfClass:[UIButton class]])
            [(UIButton *)obj setTitle:@"Connect with Facebook" forState:UIControlStateNormal];
    }
    logInController.logInView.logo = (UIView *)[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"parseLogo.png"]];
    [logInController.logInView.dismissButton setHidden:YES];
    [logInController.logInView setBackgroundColor:[UIColor colorWithRed:38.0/255.0 green:17.0/255.0 blue:25.0/225.0 alpha:1.0]];
    [self presentViewController:logInController animated:YES completion:nil];
}

- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    NSString *userId = [[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"];
    [user setValue:userId forKey:@"facebookId"];
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *myUser,
           NSError *error) {
             if (!error) {
                 [user setValue:myUser.name forKey:@"Name"];
                 [user setValue:[NSNumber numberWithInt:1] forKey:@"isVisible"];
                 [user saveInBackground];
                 [controller dismissViewControllerAnimated:YES completion:nil];
             }
         }];
    }
}

-(void)checkGroup
{
    [path removeAllCoordinates];
    PFQuery *query = [PFQuery queryWithClassName:@"Groups"];
    [query whereKey:@"isActive" equalTo:[NSNumber numberWithInt:1]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            groupsArray = [objects mutableCopy];
            for(int i = 0 ; i < [objects count] ; i++)
            {
                CLLocationCoordinate2D position = CLLocationCoordinate2DMake([[[objects objectAtIndex:i] valueForKey:@"latitude"] floatValue], [[[objects objectAtIndex:i] valueForKey:@"longitude"] floatValue]);
                GMSMarker *marker = [GMSMarker markerWithPosition:position];
                marker.title = @"Destination Point";
                marker.map = mapView;
                
                for(int j = 0 ; j < [[[objects objectAtIndex:i] valueForKey:@"people"] count]; j++)
                {
                    if(![[[[objects objectAtIndex:i] valueForKey:@"people"] objectAtIndex:j] isEqualToString:[[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"]])
                    {
                        PFQuery *userquery = [PFUser query];
                        NSString *userId = [[[objects objectAtIndex:i] valueForKey:@"people"] objectAtIndex:j];
                        [userquery whereKey:@"facebookId" equalTo:userId];
                        NSArray *userArray = [userquery findObjects];
                        for(int k = 0 ; k < [userArray count] ; k++)
                        {
                            CLLocationCoordinate2D position = CLLocationCoordinate2DMake([[[userArray objectAtIndex:k] valueForKey:@"latitude"] floatValue], [[[userArray objectAtIndex:k] valueForKey:@"longitude"] floatValue]);
                            GMSMarker *marker = [GMSMarker markerWithPosition:position];
                            marker.title = [[userArray objectAtIndex:k] valueForKey:@"Name"];
                            marker.snippet = [[userArray objectAtIndex:k] valueForKey:@"updatedAt"];
                            NSDate *lastUpdate = [[userArray objectAtIndex:k] valueForKey:@"updatedAt"];
                            NSDate *now = [NSDate date];
                            marker.map = mapView;
                            marker.userData = [[userArray objectAtIndex:k] valueForKey:@"locations"];
                            float randomRed = arc4random()%255;
                            float randomBlue = arc4random()%255;
                            float randomGreen = arc4random()%255;
                            marker.icon = [GMSMarker markerImageWithColor:[UIColor colorWithRed:randomRed/255.0 green:randomGreen/255.0 blue:randomBlue/255.0 alpha:1.0]];
                            
                            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
                            NSDateComponents *components = [calendar components:NSMinuteCalendarUnit
                                                                       fromDate:lastUpdate
                                                                         toDate:now
                                                                        options:0];
                            
                            if(components.minute > 5)
                                marker.icon = [GMSMarker markerImageWithColor:[UIColor darkGrayColor]];
                        }
                    }
                }
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    [self performSelector:@selector(checkGroup) withObject:nil afterDelay:5.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
