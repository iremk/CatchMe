//
//  LeftMenuViewController.m
//  Trafiko
//
//  Created by irem korkmaz on 3/15/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import "MenuViewController.h"
#import "UIImage+iPhone5.h"

#define NumberOfItems 3

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
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(15, (((self.view.frame.size.height)/NumberOfItems)-28)/2, 28, 28)];
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(53, (((self.view.frame.size.height)/NumberOfItems)-20)/2, 120, 28)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor whiteColor]];
    [title setFont:[UIFont fontWithName:@"ConfettiStream" size:18.0]];
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
    
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern.png"]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, (self.view.frame.size.height)/NumberOfItems)];
    [imageView setBackgroundColor:bgColor];
    [cell.contentView addSubview:imageView];
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
    return (self.view.frame.size.height)/NumberOfItems;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        [self.sidebarDelegate sidebarViewController:self didSelectObject:nil atIndexPath:indexPath];
    [menuTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
