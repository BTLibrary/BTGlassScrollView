//
//  BTGlassScrollViewController.h
//  BTGlassScrollViewExample2
//
//  Created by Byte on 1/23/14.
//  Copyright (c) 2014 Byte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTGlassScrollView.h"

@interface BTGlassScrollViewController : UIViewController
@property (nonatomic, assign) int index;
@property (nonatomic, strong) BTGlassScrollView *glassScrollView;
- (id)initWithImage:(UIImage *)image;
@end
