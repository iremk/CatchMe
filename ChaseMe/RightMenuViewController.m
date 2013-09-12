//
//  LeftMenuViewController.m
//  Trafiko
//
//  Created by irem korkmaz on 3/15/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import "RightMenuViewController.h"
#import "UIImage+iPhone5.h"
#import <Parse/Parse.h>
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "RNBlurModalView.h"
#import "SIAlertView.h"
#import "Api.h"
#import "MBProgressHUD.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"

#define CellHeight 44

@interface RightMenuViewController ()
{
    UITableView *menuTableView;
    NSMutableArray *friendsArray;
    int NumberOfItems;
    UITextField *placeTextField;
    UITableView *placesTableView;
    UITableView *friendsTableView;
    
    UIView *blurredView;
    RNBlurModalView *modal;
    NSMutableArray *groupsArray;
    
    NSMutableArray *checkedIndexPaths;
    NSMutableArray *placesResults;
    float latitude;
    float longitude;
    NSString* placeName;
    
    CLLocation *currentLocation;
    MBProgressHUD *hud;
}

@end

@implementation RightMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)checkFriendsAndGroups
{
    NSLog(@"check friends and groups");
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"receiver = '%@' OR sender = '%@'" , [[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"] , [[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"]]];
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequests" predicate:predicate];
    [query whereKey:@"isFriends" equalTo:[NSNumber numberWithInt:1]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            self->friendsArray = [objects mutableCopy];
            NumberOfItems = [friendsArray count];
            [menuTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"Groups"];
    [query2 whereKey:@"isActive" equalTo:[NSNumber numberWithInt:1]];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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
                groupsArray = [NSMutableArray arrayWithObject:[objects objectAtIndex:availableGroup]];
            else
                groupsArray = [[NSMutableArray alloc] init];
        }}];
    
    [self performSelector:@selector(checkFriendsAndGroups) withObject:nil afterDelay:10.0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    friendsArray = [[NSMutableArray alloc] init];
    groupsArray = [[NSMutableArray alloc] init];
    checkedIndexPaths = [[NSMutableArray alloc] init];
    placesResults = [[NSMutableArray alloc] init];
    currentLocation = [[Api sharedInstance] getCurrentLocation];
    NumberOfItems = 0;
    menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    [menuTableView setDataSource:self];
    [menuTableView setDelegate:self];
    [menuTableView setSeparatorColor:[UIColor darkGrayColor]];
    menuTableView.tag = 30;
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern.png"]];
    [menuTableView setBackgroundColor:bgColor];
    [self.view addSubview:menuTableView];
    
    [self checkFriendsAndGroups];
    
    placeTextField.returnKeyType = UIReturnKeyDone;
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
    
    placesTableView = [[UITableView alloc] initWithFrame:CGRectMake(20, 54, 240, (self.view.frame.size.height-40) - 118)];
    placesTableView.delegate = self;
    placesTableView.dataSource = self;
    placesTableView.tag = 10;
    [placesTableView setBackgroundColor:[UIColor clearColor]];
    [placesTableView setSeparatorColor:[UIColor whiteColor]];
    [blurredView addSubview:placesTableView];
    
    /*friendsTableView = [[UITableView alloc] initWithFrame:CGRectMake(20, (self.view.frame.size.height-40)/2-5, 240, (self.view.frame.size.height-40)/2 - 59)];
    friendsTableView.delegate = self;
    friendsTableView.dataSource = self;
    friendsTableView.tag = 20;
    [friendsTableView setBackgroundColor:[UIColor clearColor]];
    [friendsTableView setSeparatorColor:[UIColor whiteColor]];
    [blurredView addSubview:friendsTableView];*/
    
    UIButton *createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [createButton setFrame:CGRectMake(20, self.view.frame.size.height-94, 240, 44)];
    [createButton setBackgroundColor:[UIColor colorWithRed:64.0/255.0 green:27.0/255.0 blue:3.0/255.0 alpha:1.0]];
    [createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [createButton setTitle:@"Create Group" forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(create:) forControlEvents:UIControlEventTouchDown];
    [blurredView addSubview:createButton];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(![userDefaults boolForKey:@"secondTutorialShown"])
    {
        int height = 460;
        NSString *imageName0 = @"s2t2i4.png";
        if(self.view.frame.size.height > 500)
        {
            imageName0 = @"s2t2i5.png";
            height = 548;
        }
        UIView *tutorialWrapperView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, height)];
        UIImageView *tutorialView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
        [tutorialView setImage:[UIImage imageNamed:imageName0]];
        [tutorialWrapperView addSubview:tutorialView];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(320-24, 8, 20, 20)];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTitle:@"X" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont fontWithName:@"GillSans" size:20.0]];
        [button.titleLabel setTextColor:[UIColor whiteColor]];
        [tutorialWrapperView addSubview:button];
        [button addTarget:self action:@selector(closeTutorial:) forControlEvents:UIControlEventTouchDown];
        UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
        [mainWindow addSubview: tutorialWrapperView];
        [userDefaults setBool:YES forKey:@"secondTutorialShown"];
        [userDefaults synchronize];
    }
}

-(IBAction)closeTutorial:(id)sender
{
    UIButton *button = sender;
    [button.superview removeFromSuperview];
}

-(IBAction)createNewGroup:(id)sender
{
    if([checkedIndexPaths count] == 0)
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Info" andMessage:@"You need to choose friends for the group first."];
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:^(SIAlertView *alertView) {
                                  NSLog(@"Cancel Clicked");
                              }];
        [alertView show];
    }
    else
    {
        //[friendsTableView reloadData];
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
                                      [placesTableView setFrame:CGRectMake(20, 54, 240, (self.view.frame.size.height-40) - 118)];
                                      [placesTableView setScrollEnabled:YES];
                                      /*[friendsTableView setFrame:CGRectMake(20, (self.view.frame.size.height-40)/2-5, 240, (self.view.frame.size.height-40)/2 - 59)];*/
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
            [placesTableView setFrame:CGRectMake(20, 54, 240, (self.view.frame.size.height-40) - 118)];
            [placesTableView setScrollEnabled:YES];
            /*[friendsTableView setFrame:CGRectMake(20, (self.view.frame.size.height-40)/2-5, 240, (self.view.frame.size.height-40)/2 - 59)];*/
            [placeTextField setText:@""];
            [placesResults removeAllObjects];
            [placesTableView reloadData];
            modal = [[RNBlurModalView alloc] initWithView:blurredView];
            [modal show];
            //        [self performSegueWithIdentifier:@"mapToCreateSegue" sender:self];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 30)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        }
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(70, 1, CellHeight-2, CellHeight-2)];
        UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(118, 7, 150, 30)];
        [title setBackgroundColor:[UIColor clearColor]];
        [title setTextColor:[UIColor whiteColor]];
        [title setFont:[UIFont fontWithName:@"GillSans" size:16.0]];
        icon.clipsToBounds = YES;
        [icon setContentMode:UIViewContentModeScaleAspectFit];
        icon.layer.cornerRadius = 6;
        [icon setContentMode:UIViewContentModeCenter];
        
        if([[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"receiver"] isEqualToString:[[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"]])
        {
            [icon setImageWithURL:[NSURL URLWithString:[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"senderPicture"]]];
            [title setText:[NSString stringWithFormat:@"%@", [[friendsArray objectAtIndex:indexPath.row] valueForKey:@"senderName"]]];
        }
        else
        {
            [icon setImageWithURL:[NSURL URLWithString:[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"picture"]]];
            [title setText:[NSString stringWithFormat:@"%@ %@", [[friendsArray objectAtIndex:indexPath.row] valueForKey:@"firstName"] , [[friendsArray objectAtIndex:indexPath.row] valueForKey:@"lastName"]]];
        }        
        [cell.contentView addSubview:icon];
        [cell.contentView addSubview:title];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        cell.accessoryType = UITableViewCellSelectionStyleNone;

        for(int i = 0 ; i < [checkedIndexPaths count] ; i++)
        {
            if(((NSIndexPath *)[checkedIndexPaths objectAtIndex:i]).row == indexPath.row)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        return cell;
    }
    else if(tableView.tag == 20)
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
        int row = ((NSIndexPath *)[checkedIndexPaths objectAtIndex:indexPath.row]).row;
        
        if([[[friendsArray objectAtIndex:row] valueForKey:@"receiver"] isEqualToString:[[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"]])
        {
            [icon setImageWithURL:[NSURL URLWithString:[[friendsArray objectAtIndex:row] valueForKey:@"senderPicture"]]];
            [title setText:[NSString stringWithFormat:@"%@", [[friendsArray objectAtIndex:row] valueForKey:@"senderName"]]];
        }
        else
        {
            [icon setImageWithURL:[NSURL URLWithString:[[friendsArray objectAtIndex:row] valueForKey:@"picture"]]];
            [title setText:[NSString stringWithFormat:@"%@ %@", [[friendsArray objectAtIndex:row] valueForKey:@"firstName"] , [[friendsArray objectAtIndex:row] valueForKey:@"lastName"]]];
        }
        
        [cell.contentView addSubview:icon];
        [cell.contentView addSubview:title];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    if(tableView.tag == 30)
        return NumberOfItems;
    else if(tableView.tag == 20)
    {
        return [checkedIndexPaths count];
    }
    else
        return [placesResults count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 30)
        return CellHeight;
    else
        return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 30)
    {
        if([checkedIndexPaths count] == 0)
            [checkedIndexPaths addObject:indexPath];
        else
        {
            for(int i = 0 ; i < [checkedIndexPaths count] ; i++)
            {
                if(((NSIndexPath *)[checkedIndexPaths objectAtIndex:i]).row == indexPath.row)
                {
                    NSLog(@"remove");
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
        [menuTableView reloadData];
    }
    else if(tableView.tag == 10)
    {
        latitude = [[[[[placesResults objectAtIndex:indexPath.row] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"] floatValue];
        longitude = [[[[[placesResults objectAtIndex:indexPath.row] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"] floatValue];
        placeName = [[placesResults objectAtIndex:indexPath.row] valueForKey:@"name"];
    }
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView.tag == 30)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0 , 0, self.view.frame.size.width, 88)];
        UIColor* bgColor = [UIColor colorWithRed:38.0/255.0 green:17.0/255.0 blue:25.0/255.0 alpha:1.0];
        [headerView setBackgroundColor:bgColor];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 2, self.view.frame.size.width-70, 40)];
        [titleLabel setFont:[UIFont fontWithName:@"GillSans-LightItalic" size:20.0]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setText:@"Friend List"];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        
        UIButton *createButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [createButton setBackgroundColor:[UIColor clearColor]];
        [createButton.titleLabel setFont:[UIFont fontWithName:@"GillSans" size:16.0]];
        [createButton setTitle:@"Select friends and Pinite them" forState:UIControlStateNormal];
        [createButton setFrame:CGRectMake(50, 46, self.view.frame.size.width-80, 40)];
        [createButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [createButton addTarget:self action:@selector(createNewGroup:) forControlEvents:UIControlEventTouchDown];
        
        
        UIButton *createButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [createButton2 setBackgroundColor:[UIColor clearColor]];
        [createButton2 setFrame:CGRectMake(270, 55, 25, 25)];
        [createButton2 addTarget:self action:@selector(createNewGroup:) forControlEvents:UIControlEventTouchDown];
        [createButton2 setImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
        createButton2.layer.cornerRadius = 8.0;
        [createButton2.layer setCornerRadius:8.0];
        
        
        [headerView addSubview:titleLabel];
        [headerView addSubview:createButton];
        [headerView addSubview:createButton2];
        [headerView bringSubviewToFront:titleLabel];
        [headerView bringSubviewToFront:createButton];
        [headerView bringSubviewToFront:createButton2];
        return headerView;
    }
    else
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
            [titleLabel setText:@"Search Your Place to Meet"];
        [headerView addSubview:titleLabel];
        [headerView bringSubviewToFront:titleLabel];
        return headerView;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView.tag == 30)
        return 88.0;
    else
        return 36.0;
}

-(void)searchMethod
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:placeTextField.text forKey:@"placeName"];
    [params setValue:[NSString stringWithFormat:@"%lf" , currentLocation.coordinate.latitude] forKey:@"latitude"];
    [params setValue:[NSString stringWithFormat:@"%lf" , currentLocation.coordinate.longitude] forKey:@"longitude"];
    placesResults = [[Api sharedInstance] searchPlace:params];
    if([placesResults count] > 0)
    {
        [placesTableView reloadData];
    }
    [placeTextField resignFirstResponder];
    [hud hide:YES];
}

-(IBAction)search:(id)sender
{
    hud = [MBProgressHUD showHUDAddedTo:blurredView animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Searching...";
    [self performSelector:@selector(searchMethod) withObject:nil afterDelay:1.0];
}

-(IBAction)create:(id)sender
{
    if(placeName.length == 0)
    {
        placeName = @"";
        latitude = 0.0;
        longitude = 0.0;
    }
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:checkedIndexPaths forKey:@"indexPaths"];
    [params setValue:friendsArray forKey:@"friends"];
    [params setValue:[NSNumber numberWithFloat:latitude] forKey:@"latitude"];
    [params setValue:[NSNumber numberWithFloat:longitude] forKey:@"longitude"];
    [params setValue:placeName forKey:@"placeName"];
    [[Api sharedInstance] createGroup:params];
    [modal hide];
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:(MapViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"mapViewController"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
