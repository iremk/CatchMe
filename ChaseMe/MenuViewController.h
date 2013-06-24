//
//  LeftMenuViewController.h
//  Trafiko
//
//  Created by irem korkmaz on 3/15/13.
//  Copyright (c) 2013 ik. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SidebarViewControllerDelegate;

@interface MenuViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) id <SidebarViewControllerDelegate> sidebarDelegate;

@end

@protocol SidebarViewControllerDelegate <NSObject>

- (void)sidebarViewController:(MenuViewController *)sidebarViewController didSelectObject:(NSObject *)object atIndexPath:(NSIndexPath *)indexPath;

@end

