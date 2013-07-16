//
//  LeftMenuViewController.m
//  Trafiko
//
//  Created by irem korkmaz on 3/15/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import "MenuViewController.h"
#import "UIImage+iPhone5.h"
#import <Parse/Parse.h>

#define NumberOfItems 3
#define CellHeight 80

@interface MenuViewController ()
{
    UITableView *menuTableView;
}

@end

@implementation MenuViewController

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
    
    menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    [menuTableView setDataSource:self];
    [menuTableView setDelegate:self];
    [menuTableView setSeparatorColor:[UIColor clearColor]];
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern.png"]];
    [menuTableView setBackgroundColor:bgColor];
    [self.view addSubview:menuTableView];
    
	// Do any additional setup after loading the view.
//    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage tallImageNamed:@"ipad-BG-pattern.png"]];
//    [menuTableView setBackgroundColor:bgColor];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"view did appear");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(15, (CellHeight-28)/2, 28, 28)];
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(53, (CellHeight-24)/2, 120, 28)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor whiteColor]];
    [title setFont:[UIFont fontWithName:@"GillSans" size:18.0]];
    if(indexPath.row == 0)
    {
        [icon setImage:[UIImage imageNamed:@"map.png"]];
        [title setText:@"Map"];
    }
    if(indexPath.row == 1)
    {
        [icon setImage:[UIImage imageNamed:@"connect.png"]];
        [title setText:@"Connections"];
    }
    if(indexPath.row == 2)
    {
        [icon setImage:[UIImage imageNamed:@"settings.png"]];
        [title setText:@"Settings"];
    }
    [icon setContentMode:UIViewContentModeCenter];
    
    /*UIColor* bgColor = [UIColor colorWithRed:64.0/255.0 green:27.0/255.0 blue:3.0/255.0 alpha:1.0];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, CellHeight)];
    [imageView setBackgroundColor:bgColor];
    [cell.contentView addSubview:imageView];*/
    [cell.contentView addSubview:icon];
    [cell.contentView addSubview:title];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NumberOfItems;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeight;//(self.view.frame.size.height)/NumberOfItems;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        [self.sidebarDelegate sidebarViewController:self didSelectObject:nil atIndexPath:indexPath];
    [menuTableView reloadData];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0 , 0, self.view.frame.size.width, 44)];
    UIColor* bgColor = [UIColor colorWithRed:38.0/255.0 green:17.0/255.0 blue:25.0/255.0 alpha:1.0];
    [headerView setBackgroundColor:bgColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, self.view.frame.size.width-20, 40)];
    [titleLabel setFont:[UIFont fontWithName:@"GillSans-LightItalic" size:20.0]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:[[PFUser currentUser] valueForKey:@"Name"]];
    [headerView addSubview:titleLabel];
    [headerView bringSubviewToFront:titleLabel];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
