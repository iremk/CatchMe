//
//  ConnectionsViewController.m
//  ChaseMe
//
//  Created by irem korkmaz on 6/8/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import "ConnectionsViewController.h"

@interface ConnectionsViewController ()

@end

@implementation ConnectionsViewController

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
}

-(IBAction)findFriends:(id)sender
{
    FBFriendPickerViewController *friendPickerViewController = [[FBFriendPickerViewController alloc]
                                  initWithNibName:nil bundle:nil];
    friendPickerViewController.delegate = self;
    [friendPickerViewController loadData];
    friendPickerViewController.title = nil;
    friendPickerViewController.navigationItem.title = nil;
    friendPickerViewController.navigationController.title = nil;
    friendPickerViewController.navigationItem.backBarButtonItem.title = nil;
    friendPickerViewController.navigationItem.leftBarButtonItem.title = nil;
    [self.navigationController pushViewController:friendPickerViewController animated:YES];
}

-(void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker
{
    NSLog(@"secti sanırım");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
