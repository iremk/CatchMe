//
//  SettingsViewController.m
//  ChaseMe
//
//  Created by irem korkmaz on 6/8/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import "SettingsViewController.h"
#import "MapViewController.h"

@interface SettingsViewController ()
{
    NSMutableArray *friendsArray;
}

@end

@implementation SettingsViewController
@synthesize visibilitySwitch;
@synthesize friendsTableView;

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
	// Do any additional setup after loading the view.
    if([[[PFUser currentUser] valueForKey:@"isVisible"] intValue] == 1)
        [visibilitySwitch setOn:YES];
    else
        [visibilitySwitch setOn:NO];
    
    friendsArray = [[NSMutableArray alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"receiver = '%@' OR sender = '%@'" , [[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"] , [[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"]]];
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequests" predicate:predicate];
    [query whereKey:@"isFriends" equalTo:[NSNumber numberWithInt:1]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            self->friendsArray = [objects mutableCopy];
            [friendsTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    for(id obj in cell.subviews)
        if([obj isKindOfClass:[UISwitch class]])
            [obj removeFromSuperview];
    
    UILabel * title = (UILabel *)[cell viewWithTag:1];
    UISwitch * toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(223, 8, 79, 27)];
    [toggleSwitch setOnTintColor:[UIColor colorWithRed:64.0/255.0 green:27.0/255.0 blue:3.0/255.0 alpha:1.0]];
    [toggleSwitch setTag:indexPath.row];
    [toggleSwitch addTarget:self action:@selector(toggleVisibilitySwitch:) forControlEvents:UIControlEventValueChanged];
    
    if([[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"isVisible"] intValue] == 1)
        [toggleSwitch setOn:YES];
    else
        [toggleSwitch setOn:NO];
    
    [title setText:[NSString stringWithFormat:@"%@ %@", [[friendsArray objectAtIndex:indexPath.row] valueForKey:@"firstName"] , [[friendsArray objectAtIndex:indexPath.row] valueForKey:@"lastName"]]];
    [cell.contentView addSubview:toggleSwitch];
    return cell;
}

- (void) toggleVisibilitySwitch:(id)sender {
    UISwitch* switchControl = sender;
    PFObject *object = [friendsArray objectAtIndex:switchControl.tag];
    if(switchControl.on)
        [object setValue:[NSNumber numberWithInt:1] forKey:@"isVisible"];
    else
        [object setValue:[NSNumber numberWithInt:0] forKey:@"isVisible"];
    [object save];
}

-(IBAction)signOut:(id)sender
{
    [PFUser logOut];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Info" andMessage:@"You maybe need to wait for 10 minutes to log-in again."];
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              NSLog(@"Cancel Clicked");
                          }];
    [alertView show];
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:(MapViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"mapViewController"]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [friendsArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected");
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
    [titleLabel setText:@"Toggle Your Visiblity for Friends"];
    [headerView addSubview:titleLabel];
    [headerView bringSubviewToFront:titleLabel];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

-(IBAction)toggleMyVisibility:(id)sender
{
    NSLog(@"toggled");
    PFUser *currentUser = [PFUser currentUser];
    if(visibilitySwitch.isOn)
        [currentUser setValue:[NSNumber numberWithInt:1] forKey:@"isVisible"];
    else
        [currentUser setValue:[NSNumber numberWithInt:0] forKey:@"isVisible"];
    [currentUser saveInBackground];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
