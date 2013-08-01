//
//  ConnectionsViewController.m
//  ChaseMe
//
//  Created by irem korkmaz on 6/8/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import "ConnectionsViewController.h"
#import "UIImage+iPhone5.m"
#import "UIImageView+WebCache.h"

@interface ConnectionsViewController ()
{
    NSMutableArray *sentRequestsArray;
    NSMutableArray *receivedRequestsArray;
    NSMutableArray *friendsArray;
}

@end

@implementation ConnectionsViewController
@synthesize requestsTableView;

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
    self.navigationItem.backBarButtonItem.title = nil;
    sentRequestsArray = [[NSMutableArray alloc] init];
    receivedRequestsArray = [[NSMutableArray alloc] init];
    friendsArray = [[NSMutableArray alloc] init];
}

-(IBAction)findFriends:(id)sender
{
    NSMutableDictionary* params = nil;
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"Learn how to make your iOS apps social."
     title:nil
     parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 NSLog(@"User canceled request.");
             } else {
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     NSLog(@"User canceled request.");
                 } else {
                     for(int i = 0 ; i < [[urlParams objectForKey:@"idsArray"] count] ; i++)
                         [[Api sharedInstance] addFriend:[[urlParams objectForKey:@"idsArray"] objectAtIndex:i]];
                     [self getConnections];
                 }
             }
         }
     }];
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    int i = 0;
    NSMutableArray *friendIds = [[NSMutableArray alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
        if(i != 0)
            [friendIds addObject:val];
        i++;
    }
    [params setObject:friendIds forKey:@"idsArray"];
    return params;
}

-(void)getConnections
{
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequests"];
    [query whereKey:@"sender" equalTo:[[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"]];
    [query whereKey:@"isFriends" equalTo:[NSNumber numberWithInt:0]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            self->sentRequestsArray = [objects mutableCopy];
            [requestsTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    query = [PFQuery queryWithClassName:@"FriendRequests"];
    [query whereKey:@"receiver" equalTo:[[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"]];
    [query whereKey:@"isFriends" equalTo:[NSNumber numberWithInt:0]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            self->receivedRequestsArray = [objects mutableCopy];
            [requestsTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"receiver = '%@' OR sender = '%@'" , [[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"] , [[[[PFUser currentUser] valueForKey:@"authData"] valueForKey:@"facebook"] valueForKey:@"id"]]];
    query = [PFQuery queryWithClassName:@"FriendRequests" predicate:predicate];
    [query whereKey:@"isFriends" equalTo:[NSNumber numberWithInt:1]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            self->friendsArray = [objects mutableCopy];
            [requestsTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self getConnections];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    UIImageView *icon = (UIImageView *)[cell viewWithTag:1];
    UILabel * title = (UILabel *)[cell viewWithTag:2];
    if(indexPath.section == 2)
    {
        [icon setImageWithURL:[NSURL URLWithString:[[sentRequestsArray objectAtIndex:indexPath.row] valueForKey:@"picture"]]];
        [title setText:[NSString stringWithFormat:@"%@ %@", [[sentRequestsArray objectAtIndex:indexPath.row] valueForKey:@"firstName"] , [[sentRequestsArray objectAtIndex:indexPath.row] valueForKey:@"lastName"]]];
    }
    else if(indexPath.section == 1)
    {
        [icon setImageWithURL:[NSURL URLWithString:[[receivedRequestsArray objectAtIndex:indexPath.row] valueForKey:@"picture"]]];
        [title setText:[NSString stringWithFormat:@"%@ %@", [[receivedRequestsArray objectAtIndex:indexPath.row] valueForKey:@"firstName"] , [[receivedRequestsArray objectAtIndex:indexPath.row] valueForKey:@"lastName"]]];
    }
    else if(indexPath.section == 0)
    {
        [icon setImageWithURL:[NSURL URLWithString:[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"picture"]]];
        [title setText:[NSString stringWithFormat:@"%@ %@", [[friendsArray objectAtIndex:indexPath.row] valueForKey:@"firstName"] , [[friendsArray objectAtIndex:indexPath.row] valueForKey:@"lastName"]]];
    }
    return cell;
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
    if(section == 2)
        [titleLabel setText:@"Sent Requests"];
    else if(section == 1)
        [titleLabel setText:@"Received Requests"];
    else if(section == 0)
        [titleLabel setText:@"Friends"];
    [headerView addSubview:titleLabel];
    [headerView bringSubviewToFront:titleLabel];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 2)
        return [sentRequestsArray count];
    else if(section == 1)
        return [receivedRequestsArray count];
    else if(section == 0)
        return [friendsArray count];
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Info" andMessage:@"Do you accept this invitation or do you ignore?"];
        [alertView addButtonWithTitle:@"Ignore"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:^(SIAlertView *alertView) {
                                  PFObject *object = [receivedRequestsArray objectAtIndex:indexPath.row];
                                  [object delete];
                                  [requestsTableView reloadData];

                              }];
        [alertView addButtonWithTitle:@"Accept"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  PFObject *object = [receivedRequestsArray objectAtIndex:indexPath.row];
                                  [object setValue:[NSNumber numberWithInt:1] forKey:@"isFriends"];
                                  [object setValue:[NSNumber numberWithInt:1] forKey:@"isVisible"];
                                  [object save];
                                  [requestsTableView reloadData];

                              }];
        [alertView show];
    }
    else if(indexPath.section == 2)
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Info" andMessage:@"Do you want to ignore this invitation?"];
        [alertView addButtonWithTitle:@"Cancel"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:^(SIAlertView *alertView) {
                                  NSLog(@"Cancelled");
                                  
                              }];
        [alertView addButtonWithTitle:@"Ignore"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  PFObject *object = [sentRequestsArray objectAtIndex:indexPath.row];
                                  [object delete];
                                  [requestsTableView reloadData];                                  
                              }];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
