//
//  LeftMenuViewController.h
//  Trafiko
//
//  Created by irem korkmaz on 3/15/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"

@protocol RightSidebarViewControllerDelegate;

@interface RightMenuViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) id <RightSidebarViewControllerDelegate> sidebarDelegate;

@end

@protocol RightSidebarViewControllerDelegate <NSObject>

- (void)sidebarViewController:(RightMenuViewController *)sidebarViewController didSelectObject:(NSObject *)object atIndexPath:(NSIndexPath *)indexPath;

@end

