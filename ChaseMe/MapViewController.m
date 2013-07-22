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
    
    NSMutableArray *friendsArray;
    NSMutableArray *checkedIndexPaths;
    NSMutableArray *placesResults;
    float latitude;
    float longitude;
    NSString* placeName;
    
    UITextField *placeTextField;
    UITableView *placesTableView;
    UITableView *friendsTableView;
    
    UIView *blurredView;
    RNBlurModalView *modal;
}

@end

@implementation MapViewController
@synthesize mapView;
@synthesize createNewButton;
@synthesize centralizeButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [createNewButton setBackgroundColor:[[UIColor colorWithRed:64.0/255.0 green:27.0/255.0 blue:3.0/255.0 alpha:1.0] colorWithAlphaComponent:1.0f]];
    createNewButton.layer.cornerRadius = 8;
    [createNewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [createNewButton.titleLabel setFont:[UIFont fontWithName:@"GillSans" size:20.0]];
    [createNewButton setTitle:@"New" forState:UIControlStateNormal];
    createNewButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    centralizeButton.layer.cornerRadius = 8;
    groupsArray = [[NSMutableArray alloc] init];
    
    placeTextField.returnKeyType = UIReturnKeyDone;
    friendsArray = [[NSMutableArray alloc] init];
    checkedIndexPaths = [[NSMutableArray alloc] init];
    placesResults = [[NSMutableArray alloc] init];
    
    blurredView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, self.view.frame.size.height-40)];
    blurredView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
    blurredView.layer.cornerRadius = 8;
    placeTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 140, 40)];
    [placeTextField setBorderStyle:UITextBorderStyleLine];
    [placeTextField setTextColor:[UIColor whiteColor]];
    [placeTextField setFont:[UIFont fontWithName:@"GillSans-Light" size:24.0]];
    placeTextField.layer.cornerRadius=8.0f;
    placeTextField.layer.masksToBounds=YES;
    placeTextField.layer.borderColor=[[UIColor whiteColor]CGColor];
    placeTextField.layer.borderWidth= 1.0f;
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setFrame:CGRectMake(180, 10, 80, 40)];
    [searchButton setBackgroundColor:[UIColor colorWithRed:64.0/255.0 green:27.0/255.0 blue:3.0/255.0 alpha:1.0]];
    [searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [searchButton setTitle:@"Search" forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchDown];
    
    [blurredView addSubview:placeTextField];
    [blurredView addSubview:searchButton];
    
    placesTableView = [[UITableView alloc] initWithFrame:CGRectMake(20, 54, 240, (self.view.frame.size.height-40)/2 - 59)];
    placesTableView.delegate = self;
    placesTableView.dataSource = self;
    placesTableView.tag = 10;
    [placesTableView setBackgroundColor:[UIColor clearColor]];
    [placesTableView setSeparatorColor:[UIColor whiteColor]];
    [blurredView addSubview:placesTableView];
    
    friendsTableView = [[UITableView alloc] initWithFrame:CGRectMake(20, (self.view.frame.size.height-40)/2-5, 240, (self.view.frame.size.height-40)/2 - 59)];
    friendsTableView.delegate = self;
    friendsTableView.dataSource = self;
    friendsTableView.tag = 20;
    [friendsTableView setBackgroundColor:[UIColor clearColor]];
    [friendsTableView setSeparatorColor:[UIColor whiteColor]];
    [blurredView addSubview:friendsTableView];
    
    UIButton *createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [createButton setFrame:CGRectMake(20, self.view.frame.size.height-94, 240, 44)];
    [createButton setBackgroundColor:[UIColor colorWithRed:64.0/255.0 green:27.0/255.0 blue:3.0/255.0 alpha:1.0]];
    [createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [createButton setTitle:@"Create" forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(create:) forControlEvents:UIControlEventTouchDown];
    [blurredView addSubview:createButton];
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"receiver = '%@' OR sender = '%@'" , [[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"] , [[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"]]];
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequests" predicate:predicate];
    [query whereKey:@"isFriends" equalTo:[NSNumber numberWithInt:1]];
    [query whereKey:@"isVisible" equalTo:[NSNumber numberWithInt:1]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            /*for(int i = 0 ; i < [objects count] ; i++)
             {
             PFQuery *userquery = [PFUser query];
             if([[[objects objectAtIndex:i] valueForKey:@"sender"] isEqualToString:[[PFUser currentUser] valueForKey:@"facebookId"]])
             [userquery whereKey:@"facebookId" equalTo:[[objects objectAtIndex:i] valueForKey:@"receiver"]];
             else
             [userquery whereKey:@"facebookId" equalTo:[[objects objectAtIndex:i] valueForKey:@"sender"]];
             NSArray *userArray = [userquery findObjects];
             for(int k = 0 ; k < [userArray count] ; k++)
             {
             if([[[userArray objectAtIndex:k] valueForKey:@"isVisible"] intValue] == 1)
             [friendsArray addObject:[objects objectAtIndex:i]];
             }
             }*/
            self->friendsArray = [objects mutableCopy];
            [friendsTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
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

- (void)mapView:(GMSMapView *)inMapView
didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Info" andMessage:@"Are you sure to create that group?"];
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              NSLog(@"Cancel Clicked");
                          }];
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              PFObject *groupObject = [groupsArray objectAtIndex:0];
                              [groupObject setValue:[NSNumber numberWithInt:0] forKey:@"isActive"];
                              [groupObject save];
                              //[self performSegueWithIdentifier:@"mapToCreateSegue" sender:self];
                              
                              NSMutableArray *checkedIndexPaths = [[NSMutableArray alloc] init];
                              NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
                              [params setValue:checkedIndexPaths forKey:@"indexPaths"];
                              [params setValue:friendsArray forKey:@"friends"];
                              [params setValue:[NSNumber numberWithFloat:coordinate.latitude] forKey:@"latitude"];
                              [params setValue:[NSNumber numberWithFloat:coordinate.longitude] forKey:@"longitude"];
                              [params setValue:@"Destination Point" forKey:@"placeName"];
                              [[Api sharedInstance] createGroup:params];
                              [mapView clear];
                              [self performSelector:@selector(checkGroup) withObject:nil afterDelay:1.0];
                          }];
    [alertView show];
}

-(UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    UIView *markerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    [markerView setBackgroundColor:[UIColor colorWithRed:64.0/255.0 green:27.0/255.0 blue:3.0/255.0 alpha:1.0]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont fontWithName:@"GillSans-Light" size:14.0]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:marker.title];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [markerView addSubview:titleLabel];
    markerView.layer.cornerRadius = 8;
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
    PFQuery *query = [PFQuery queryWithClassName:@"Groups"];
    [query whereKey:@"isActive" equalTo:[NSNumber numberWithInt:1]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            //NSLog(@"bakiom aga %@" , objects);
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
                            marker.map = mapView;
                            float randomRed = arc4random()%255;
                            float randomBlue = arc4random()%255;
                            float randomGreen = arc4random()%255;
                            marker.icon = [GMSMarker markerImageWithColor:[UIColor colorWithRed:randomRed/255.0 green:randomGreen/255.0 blue:randomBlue/255.0 alpha:1.0]];
                        }
                    }
                }
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(IBAction)createNewGroup:(id)sender
{
    if([groupsArray count] > 0)
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Info" andMessage:@"Are you sure to leave the group?"];
        [alertView addButtonWithTitle:@"No"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:^(SIAlertView *alertView) {
                                  NSLog(@"Cancel Clicked");
                              }];
        [alertView addButtonWithTitle:@"Yes"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  PFObject *groupObject = [groupsArray objectAtIndex:0];
                                  [groupObject setValue:[NSNumber numberWithInt:0] forKey:@"isActive"];
                                  [groupObject save];
                                  //[self performSegueWithIdentifier:@"mapToCreateSegue" sender:self];
                                  [placesTableView setFrame:CGRectMake(20, 54, 240, (self.view.frame.size.height-40)/2 - 59)];
                                  [placesTableView setScrollEnabled:YES];
                                  [friendsTableView setFrame:CGRectMake(20, (self.view.frame.size.height-40)/2-5, 240, (self.view.frame.size.height-40)/2 - 59)];
                                  [placeTextField setText:@""];
                                  [placesResults removeAllObjects];
                                  [placesTableView reloadData];
                                  modal = [[RNBlurModalView alloc] initWithView:blurredView];
                                  [modal show];
                              }];
        [alertView show];
    }
    else
    {
        [placesTableView setFrame:CGRectMake(20, 54, 240, (self.view.frame.size.height-40)/2 - 59)];
        [placesTableView setScrollEnabled:YES];
        [friendsTableView setFrame:CGRectMake(20, (self.view.frame.size.height-40)/2-5, 240, (self.view.frame.size.height-40)/2 - 59)];
        [placeTextField setText:@""];
        [placesResults removeAllObjects];
        [placesTableView reloadData];
        modal = [[RNBlurModalView alloc] initWithView:blurredView];
        [modal show];
//        [self performSegueWithIdentifier:@"mapToCreateSegue" sender:self];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 20)
    {
        static NSString *CellIdentifier = @"FriendCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        }
        
        for(id obj in cell.contentView.subviews)
            [obj removeFromSuperview];
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 4, 52, 52)];
        UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(72, 14, 188, 32)];
        [title setBackgroundColor:[UIColor clearColor]];
        [title setTextColor:[UIColor whiteColor]];
        [title setFont:[UIFont fontWithName:@"GillSans" size:16.0]];
        [icon setImageWithURL:[NSURL URLWithString:[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"picture"]]];
        [title setText:[NSString stringWithFormat:@"%@ %@", [[friendsArray objectAtIndex:indexPath.row] valueForKey:@"firstName"] , [[friendsArray objectAtIndex:indexPath.row] valueForKey:@"lastName"]]];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        for(int i = 0 ; i < [checkedIndexPaths count] ; i++)
        {
            if(((NSIndexPath *)[checkedIndexPaths objectAtIndex:i]).row == indexPath.row)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        [cell.contentView addSubview:icon];
        [cell.contentView addSubview:title];
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"PlaceCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        }
        
        for(id obj in cell.contentView.subviews)
            [obj removeFromSuperview];
        
        UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 220, 32)];
        [title setBackgroundColor:[UIColor clearColor]];
        [title setTextColor:[UIColor whiteColor]];
        [title setFont:[UIFont fontWithName:@"GillSans" size:16.0]];
    
        UILabel * address = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 220, 20)];
        [address setBackgroundColor:[UIColor clearColor]];
        [address setTextColor:[UIColor whiteColor]];
        [address setFont:[UIFont fontWithName:@"GillSans-Light" size:12.0]];
        
        [title setText:[NSString stringWithFormat:@"%@", [[placesResults objectAtIndex:indexPath.row] valueForKey:@"name"]]];
        [address setText:[NSString stringWithFormat:@"%@", [[placesResults objectAtIndex:indexPath.row] valueForKey:@"formatted_address"]]];
        
        [cell.contentView addSubview:title];
        [cell.contentView addSubview:address];
        return cell;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == 20)
        return [friendsArray count];
    else
        return [placesResults count];
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 20)
        return 60;
    else
        return 60;
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 20)
    {
        if([checkedIndexPaths count] == 0)
            [checkedIndexPaths addObject:indexPath];
        else
        {
            for(int i = 0 ; i < [checkedIndexPaths count] ; i++)
            {
                if(((NSIndexPath *)[checkedIndexPaths objectAtIndex:i]).row == indexPath.row)
                {
                    [checkedIndexPaths removeObjectAtIndex:i];
                    break;
                }
                if(i == [checkedIndexPaths count] - 1)
                {
                    [checkedIndexPaths addObject:indexPath];
                    break;
                }
            }
        }
        [friendsTableView reloadData];
    }
    else
    {
        latitude = [[[[[placesResults objectAtIndex:indexPath.row] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"] floatValue];
        longitude = [[[[[placesResults objectAtIndex:indexPath.row] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"] floatValue];
        placeName = [[placesResults objectAtIndex:indexPath.row] valueForKey:@"name"];
        [UIView animateWithDuration:1.0 animations:^
         {
             int y = placesTableView.frame.origin.y;
             int height = placesTableView.frame.size.height;
             [placesTableView setFrame:CGRectMake(20, placesTableView.frame.origin.y, 240, 100)];
             [placesTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
             [placesTableView setScrollEnabled:NO];
             [friendsTableView setFrame:CGRectMake(20, y+110, 240, height-100+friendsTableView.frame.size.height)];
         } completion:^(BOOL finished)
         {
             //type here what you want your program to do after the animation finished
             
         }];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0 , 0, self.view.frame.size.width, 40)];
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern.png"]];
    [headerView setBackgroundColor:bgColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, self.view.frame.size.width-20, 36)];
    [titleLabel setFont:[UIFont fontWithName:@"GillSans" size:16.0]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    if(tableView.tag == 20)
        [titleLabel setText:@"Add Friends to New Group"];
    else
        [titleLabel setText:@"Choose Your Place"];
    [headerView addSubview:titleLabel];
    [headerView bringSubviewToFront:titleLabel];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

-(IBAction)create:(id)sender
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:checkedIndexPaths forKey:@"indexPaths"];
    [params setValue:friendsArray forKey:@"friends"];
    [params setValue:[NSNumber numberWithFloat:latitude] forKey:@"latitude"];
    [params setValue:[NSNumber numberWithFloat:longitude] forKey:@"longitude"];
    [params setValue:placeName forKey:@"placeName"];
    [[Api sharedInstance] createGroup:params];
//    [self.navigationController popViewControllerAnimated:YES];
    [modal hide];
}

-(IBAction)search:(id)sender
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:placeTextField.text forKey:@"placeName"];
    [params setValue:[NSString stringWithFormat:@"%lf" , self.currentLocation.coordinate.latitude] forKey:@"latitude"];
    [params setValue:[NSString stringWithFormat:@"%lf" , self.currentLocation.coordinate.longitude] forKey:@"longitude"];
    placesResults = [[Api sharedInstance] searchPlace:params];
    if([placesResults count] > 0)
    {
        [placesTableView reloadData];
    }
    [placeTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
