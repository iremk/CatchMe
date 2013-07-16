//
//  CreateViewController.m
//  CatchMe
//
//  Created by irem korkmaz on 7/6/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import "CreateViewController.h"

@interface CreateViewController ()
{
    NSMutableArray *friendsArray;
    NSMutableArray *checkedIndexPaths;
    NSMutableArray *placesResults;
    float latitude;
    float longitude;
    NSString* placeName;
}

@end

@implementation CreateViewController
@synthesize placeTextField;
@synthesize placesTableView;
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
    placeTextField.returnKeyType = UIReturnKeyDone;
    friendsArray = [[NSMutableArray alloc] init];
    checkedIndexPaths = [[NSMutableArray alloc] init];
    placesResults = [[NSMutableArray alloc] init];
}

-(void)viewDidAppear:(BOOL)animated
{
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
        UIImageView *icon = (UIImageView *)[cell viewWithTag:21];
        UILabel * title = (UILabel *)[cell viewWithTag:22];
        [icon setImageWithURL:[NSURL URLWithString:[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"picture"]]];
        [title setText:[NSString stringWithFormat:@"%@ %@", [[friendsArray objectAtIndex:indexPath.row] valueForKey:@"firstName"] , [[friendsArray objectAtIndex:indexPath.row] valueForKey:@"lastName"]]];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        for(int i = 0 ; i < [checkedIndexPaths count] ; i++)
        {
            if(((NSIndexPath *)[checkedIndexPaths objectAtIndex:i]).row == indexPath.row)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"PlaceCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        }
        UILabel * title = (UILabel *)[cell viewWithTag:11];
        UILabel * address = (UILabel *)[cell viewWithTag:12];
        [title setText:[NSString stringWithFormat:@"%@", [[placesResults objectAtIndex:indexPath.row] valueForKey:@"name"]]];
        [address setText:[NSString stringWithFormat:@"%@", [[placesResults objectAtIndex:indexPath.row] valueForKey:@"formatted_address"]]];
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
    [self.navigationController popViewControllerAnimated:YES];
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
