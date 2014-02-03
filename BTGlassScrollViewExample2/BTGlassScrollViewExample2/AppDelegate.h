//
//  AppDelegate.h
//  BTGlassScrollViewExample2
//
//  Created by Byte on 1/23/14.
//  Copyright (c) 2014 Byte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTGlassScrollViewController.h"

@interface AppDelegate : UIResponder <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
