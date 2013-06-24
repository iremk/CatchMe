//
//  FriendPickerViewController.m
//  ChaseMe
//
//  Created by irem korkmaz on 6/8/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import "FriendPickerViewController.h"

@interface FriendPickerViewController ()

@end

@implementation FriendPickerViewController
@synthesize selectionView;

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
}

-(void)viewDidAppear:(BOOL)animated
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
    selectionView = friendPickerViewController.view;
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
