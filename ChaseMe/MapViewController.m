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
    bool visible;
}

@end

@implementation MapViewController
@synthesize mapView;
@synthesize centralizeButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    visible = YES;
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
    NSString *imageName5 = @"rightMenuTutorial4.png";
    if(self.view.frame.size.height > 960)
    {
        imageName0 = @"tutorialChar5.png";
        imageName1 = @"openingTutorial5.png";
        imageName2 = @"createGroupTutorial5.png";
        imageName3 = @"connectionsTutorial5.png";
        imageName4 = @"settingsTutorial5.png";
        imageName5 = @"rightMenuTutorial5.png";
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
        MYIntroductionPanel *panel5 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:imageName5]   description:@""];
        
        /*A more customized version*/
        MYIntroductionView *introductionView = [[MYIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) headerText:@"Tutorial" panels:@[panel0,panel, panel5,panel2, panel3,panel4] languageDirection:MYLanguageDirectionLeftToRight];
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
    UIView *markerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 60)];
    [markerView setBackgroundColor:[UIColor colorWithRed:64.0/255.0 green:27.0/255.0 blue:3.0/255.0 alpha:1.0]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 32)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont fontWithName:@"GillSans-Light" size:16.0]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:marker.title];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    if(![marker.title isEqualToString:@"Destination Point"])
    {
        [titleLabel setFrame:CGRectMake(60, 0, 120, 32)];
        UILabel *titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(60, 34, 120, 24)];
        [titleLabel2 setBackgroundColor:[UIColor clearColor]];
        titleLabel2.numberOfLines = 2;
        [titleLabel2 setFont:[UIFont fontWithName:@"GillSans-Light" size:10.0]];
        [titleLabel2 setTextColor:[UIColor whiteColor]];
        [titleLabel2 setText:[NSString stringWithFormat:@"Last seen : %@" , marker.snippet]];
        [titleLabel2 setTextAlignment:NSTextAlignmentCenter];
    
        UIImageView *pictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 48, 48)];
        [pictureImageView setImageWithURL:[NSURL URLWithString:[marker.userData valueForKey:@"picture"]]];
        pictureImageView.layer.cornerRadius = 8;
        [markerView addSubview:titleLabel2];
        [markerView addSubview:pictureImageView];
    }
    else
    {
        UILabel *titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 34, 180, 24)];
        [titleLabel2 setBackgroundColor:[UIColor clearColor]];
        titleLabel2.numberOfLines = 2;
        [titleLabel2 setFont:[UIFont fontWithName:@"GillSans-Light" size:10.0]];
        [titleLabel2 setTextColor:[UIColor whiteColor]];
        [titleLabel2 setText:[NSString stringWithFormat:@"Address : %@" , marker.snippet]];
        [titleLabel2 setTextAlignment:NSTextAlignmentCenter];
        
        [markerView addSubview:titleLabel2];
    }
    [markerView addSubview:titleLabel];
    markerView.layer.cornerRadius = 8;
    
    /*GMSPolyline *polyline = [[GMSPolyline alloc] init];
    NSString *locations = [marker.userData valueForKey:@"locations"];
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
    polyline.map = mapView;*/
    
    return markerView;
}

-(void)drawPolylineToMap:(NSNotification*)notification
{
    /*GMSPolyline *polyline = [[GMSPolyline alloc] init];
    [path removeAllCoordinates];
    for(int i = 0 ; i < 5 ; i++)
    {
        [path addCoordinate:((CLLocation *)[self.myLocations objectAtIndex:i]).coordinate];
    }
    polyline.path = path;
    polyline.strokeColor = [UIColor redColor];
    polyline.strokeWidth = 2.f;
    polyline.map = mapView;*/
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
                 [user setValue:[[Api sharedInstance] getPictureURL:userId] forKey:@"picture"];
                 [user saveInBackground];
                 [controller dismissViewControllerAnimated:YES completion:nil];
             }
         }];
    }
}

-(void)checkGroup
{
    PFUser *currentUser = [PFUser currentUser];
    CLLocation *newLocation = [self.locationManager location];
    if(currentUser)
    {
        [currentUser setValue:[NSNumber numberWithFloat:newLocation.coordinate.latitude] forKey:@"latitude"];
        [currentUser setValue:[NSNumber numberWithFloat:newLocation.coordinate.longitude] forKey:@"longitude"];
        [currentUser saveInBackground];
    }
    [self.myLocations addObject:newLocation];
    if([self.myLocations count] == 6)
    {
        [self.myLocations removeObjectAtIndex:0];
        PFUser *user = [PFUser currentUser];
        [user setObject:[[Api sharedInstance] convertLocationsToString:self.myLocations] forKey:@"locations"];
        [user saveInBackground];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Groups"];
    [query whereKey:@"isActive" equalTo:[NSNumber numberWithInt:1]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            groupsArray = [objects mutableCopy];
            NSString *userId = [[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"];
            int control = 0;
            int availableGroup = 0;
            for(int i = 0 ; i < [groupsArray count] ; i++)
            {
                for(int j = 0 ; j < [[[groupsArray objectAtIndex:i] valueForKey:@"people"] count]; j++)
                {
                    if([userId isEqualToString:[[[groupsArray objectAtIndex:i] valueForKey:@"people"] objectAtIndex:j]])
                    {
                        control = 1;
                        availableGroup = i;
                        break;
                    }                    
                }
            }
            if(control == 1)
            {
                [path removeAllCoordinates];
                [mapView clear];
                CLLocationCoordinate2D position = CLLocationCoordinate2DMake([[[objects objectAtIndex:availableGroup] valueForKey:@"latitude"] floatValue], [[[objects objectAtIndex:availableGroup] valueForKey:@"longitude"] floatValue]);
                GMSMarker *marker = [GMSMarker markerWithPosition:position];
                marker.title = @"Destination Point";
                marker.snippet = [[objects objectAtIndex:availableGroup] valueForKey:@"placeName"];
                marker.map = mapView;
                
                for(int j = 0 ; j < [[[objects objectAtIndex:availableGroup] valueForKey:@"people"] count]; j++)
                {
                    if(![[[[objects objectAtIndex:availableGroup] valueForKey:@"people"] objectAtIndex:j] isEqualToString:[[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"]])
                    {
                        PFQuery *visibilityQuery = [PFQuery queryWithClassName:@"FriendRequests"];
                        [visibilityQuery whereKey:@"sender" equalTo:[[[objects objectAtIndex:availableGroup] valueForKey:@"people"] objectAtIndex:j]];
                        [visibilityQuery whereKey:@"receiver" equalTo:[[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"]];
                        [visibilityQuery whereKey:@"isVisible" equalTo:[NSNumber numberWithInt:0]];
                        NSMutableArray *visibility1 = [[visibilityQuery findObjects] mutableCopy];
                        
                        PFQuery *visibilityQuery2 = [PFQuery queryWithClassName:@"FriendRequests"];
                        [visibilityQuery2 whereKey:@"receiver" equalTo:[[[objects objectAtIndex:availableGroup] valueForKey:@"people"] objectAtIndex:j]];
                        [visibilityQuery2 whereKey:@"sender" equalTo:[[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"]];
                        [visibilityQuery2 whereKey:@"isVisible" equalTo:[NSNumber numberWithInt:0]];
                        NSMutableArray *visibility2 = [[visibilityQuery2 findObjects] mutableCopy];
                        
                        if([visibility1 count] == 0 && [visibility2 count] == 0)
                        {
                            PFQuery *userquery = [PFUser query];
                            NSString *userId = [[[objects objectAtIndex:availableGroup] valueForKey:@"people"] objectAtIndex:j];
                            [userquery whereKey:@"facebookId" equalTo:userId];
                            [userquery findObjectsInBackgroundWithBlock:^(NSArray *userArray, NSError *error){
                                for(int k = 0 ; k < [userArray count] ; k++)
                                {
                                    CLLocationCoordinate2D position = CLLocationCoordinate2DMake([[[userArray objectAtIndex:k] valueForKey:@"latitude"] floatValue], [[[userArray objectAtIndex:k] valueForKey:@"longitude"] floatValue]);
                                    GMSMarker *marker = [GMSMarker markerWithPosition:position];
                                    marker.title = [[userArray objectAtIndex:k] valueForKey:@"Name"];
                                    NSDate *lastUpdate = [[userArray objectAtIndex:k] valueForKey:@"updatedAt"];
                                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
                                    NSString *dateString = [formatter stringFromDate:lastUpdate];
                                    dateString = [dateString stringByAppendingString:@" GMT"];
                                    marker.snippet = dateString;
                                    NSDate *now = [NSDate date];
                                    marker.map = mapView;
                                    NSMutableDictionary *userDataDictionary = [[NSMutableDictionary alloc] init];
                                    [userDataDictionary setValue:[[userArray objectAtIndex:k] valueForKey:@"locations"] forKey:@"locations"];
                                    [userDataDictionary setValue:[[userArray objectAtIndex:k] valueForKey:@"picture"] forKey:@"picture"];
                                    marker.userData = userDataDictionary;
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
                            }];
                        }
                    }
                }
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    if(visible)
        [self performSelector:@selector(checkGroup) withObject:nil afterDelay:15.0];
}

-(void)viewDidDisappear:(BOOL)animated
{
    visible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
