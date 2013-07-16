//
//  CreateViewController.h
//  CatchMe
//
//  Created by irem korkmaz on 7/6/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import "BaseViewController.h"
#import "UIImageView+WebCache.h"

@interface CreateViewController : BaseViewController <UITextFieldDelegate>

@property (nonatomic , strong) IBOutlet UITextField *placeTextField;
@property (nonatomic , strong) IBOutlet UITableView *placesTableView;
@property (nonatomic , strong) IBOutlet UITableView *friendsTableView;

-(IBAction) search:(id)sender;
-(IBAction)create:(id)sender;

@end
