//
//  SettingsViewController.h
//  ChaseMe
//
//  Created by irem korkmaz on 6/8/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SettingsViewController : BaseViewController

@property (nonatomic , strong) IBOutlet UISwitch *visibilitySwitch;
-(IBAction)toggleMyVisibility:(id)sender;

@property (nonatomic , strong) IBOutlet UITableView *friendsTableView;

@end
