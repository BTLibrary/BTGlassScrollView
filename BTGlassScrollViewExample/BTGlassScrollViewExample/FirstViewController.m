//
//  FirstViewController.m
//  BTGlassScrollViewExample
//
//  Created by Byte on 10/21/13.
//  Copyright (c) 2013 Byte. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setFrame:self.view.frame];
        [button setTitle:@"GO TO THE MAIN APP" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(goToViewController) forControlEvents:UIControlEventTouchUpInside];
        [button setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self.view addSubview:button];
        
    }
    return self;
}

- (void)goToViewController
{
    [self.navigationController pushViewController:[[ViewController alloc] init] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
