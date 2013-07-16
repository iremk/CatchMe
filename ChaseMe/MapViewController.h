//
//  ViewController.h
//  ChaseMe
//
//  Created by irem korkmaz on 6/7/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "RNBlurModalView.h"

@interface MapViewController : BaseViewController <PFLogInViewControllerDelegate , GMSMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic , strong) IBOutlet GMSMapView *mapView;
@property (nonatomic , strong) IBOutlet UIButton *createNewButton;
@property (nonatomic , strong) IBOutlet UIButton *centralizeButton;

-(IBAction)createNewGroup:(id)sender;
-(IBAction)centralize:(id)sender;

@end
