//
//  ConnectionsViewController.h
//  ChaseMe
//
//  Created by irem korkmaz on 6/8/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ConnectionsViewController : BaseViewController <FBFriendPickerDelegate>

-(IBAction)findFriends:(id)sender;

@end
