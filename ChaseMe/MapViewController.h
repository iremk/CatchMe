//
//  ViewController.h
//  ChaseMe
//
//  Created by irem korkmaz on 6/7/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MapViewController : BaseViewController <PFLogInViewControllerDelegate>

@property (nonatomic , strong) IBOutlet GMSMapView *mapView;

@end
