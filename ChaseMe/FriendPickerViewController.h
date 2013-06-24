//
//  FriendPickerViewController.h
//  ChaseMe
//
//  Created by irem korkmaz on 6/8/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendPickerViewController : UIViewController <FBFriendPickerDelegate>

@property (nonatomic , strong) IBOutlet UIView *selectionView;

@end
