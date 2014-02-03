//
//  AppDelegate.m
//  BTGlassScrollViewExample2
//
//  Created by Byte on 1/23/14.
//  Copyright (c) 2014 Byte. All rights reserved.
//

#import "AppDelegate.h"

#define NUMBER_OF_PAGES 5

@implementation AppDelegate
{
    NSMutableArray *_viewControllerArray;
    int _currentIndex;
    CGFloat _glassScrollOffset;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    _viewControllerArray = [NSMutableArray array];
    UINavigationController *glassScrollVCWithNavC = [self glassScrollVCWithNavigatorForIndex:0];
    _viewControllerArray[0] = glassScrollVCWithNavC;
    
    UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:0];
    [pageViewController setViewControllers:_viewControllerArray direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [pageViewController.view setBackgroundColor:[UIColor blackColor]];
    [pageViewController setDelegate:self];
    [pageViewController setDataSource:self];
    
    
    // THIS IS A HACK INTO THE PAGEVIEWCONTROLLER
    // PROCEED WITH CAUTION
    // MAY CONTAIN BUG!! (I HAVENT RAN INTO ONE YET)
    // looking for the subview that is a scrollview so we can attach a delegate onto the view to mornitor scrolling
    for (UIView *subview in pageViewController.view.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollview = (UIScrollView *) subview;
            [scrollview setDelegate:self];
        }
    }
    
    self.window.rootViewController = pageViewController;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Delegate & Datasource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    BTGlassScrollViewController *currentGlass = ((BTGlassScrollViewController*)(((UINavigationController *)viewController).viewControllers)[0]);
    _currentIndex = currentGlass.index;
    int replacementIndex = _currentIndex - 1;
    
    if (replacementIndex < 0) {
        return nil;
    }
    
    return _viewControllerArray[replacementIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    BTGlassScrollViewController *currentGlass = (BTGlassScrollViewController*)(((UINavigationController *)viewController).viewControllers)[0];
    _currentIndex = currentGlass.index;
    int replacementIndex = _currentIndex + 1;
    
    if (replacementIndex == NUMBER_OF_PAGES) {
        return nil;
    }
    
    UINavigationController *replacementViewController;
    if (_viewControllerArray.count == replacementIndex) {
        replacementViewController = [self glassScrollVCWithNavigatorForIndex:replacementIndex];
        _viewControllerArray[replacementIndex] = replacementViewController;
    } else {
        replacementViewController = _viewControllerArray[replacementIndex];
    }
    return replacementViewController;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    UINavigationController *navVC = _viewControllerArray[_currentIndex];
    BTGlassScrollViewController *glassVC = navVC.viewControllers[0];
    
    UINavigationController *pendingNavVC = pendingViewControllers[0];
    BTGlassScrollViewController *pendingGlassVC = pendingNavVC.viewControllers[0];
    
    [pendingGlassVC.glassScrollView scrollVerticallyToOffset:glassVC.glassScrollView.foregroundScrollView.contentOffset.y];
    
    //this is a hack to make sure the blur does exactly what it should do
    if (glassVC.glassScrollView.foregroundScrollView.contentOffset.y > 0) {
        [pendingGlassVC.glassScrollView blurBackground:YES];
    }
}

#pragma mark UIScrollview
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // This is a custom ScrollView (private to Apple)
    // I found that they resets the scrolling everytime the viewController comes to rest
    // it rests at 360 (or width), left scroll causes it to decrease, right causes increase
    
    CGFloat ratio = (scrollView.contentOffset.x / scrollView.frame.size.width) - 1;
    
    
    // prevent any crazy behaviour due to lag
    // sometimes it resets itself when comes to reset and show crazy jumps
    if (ratio == 0) {
        return;
    }

    // retrieve views with index and +/- 1
    [((BTGlassScrollViewController*)(((UINavigationController *)_viewControllerArray[_currentIndex]).viewControllers)[0]).glassScrollView scrollHorizontalRatio:-ratio];
    
    if (_currentIndex != 0) {
        // do the previous scroll
        [((BTGlassScrollViewController*)(((UINavigationController *)_viewControllerArray[_currentIndex - 1]).viewControllers)[0]).glassScrollView scrollHorizontalRatio:-ratio-1];
    }
    
    if (_currentIndex != (_viewControllerArray.count - 1)) {
        // do the next scroll
        [((BTGlassScrollViewController*)(((UINavigationController *)_viewControllerArray[_currentIndex + 1]).viewControllers)[0]).glassScrollView scrollHorizontalRatio:-ratio+1];
    }

}

#pragma mark - Make views
// This method is useful when you want navigation bar, Otherwise return BTGlassScrollViewController object instead
- (UINavigationController *)glassScrollVCWithNavigatorForIndex:(int)index
{
    //Here is where you create your next view!
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: [self glassScrollViewControllerForIndex:index]];
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowOffset:CGSizeMake(1, 1)];
    [shadow setShadowColor:[UIColor blackColor]];
    [shadow setShadowBlurRadius:1];
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSShadowAttributeName: shadow};

    //weird voodoo to remove navigation bar background
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar setShadowImage:[UIImage new]];
    
    return navigationController;
}

- (BTGlassScrollViewController *)glassScrollViewControllerForIndex:(int)index
{
    // This is just an example for a glassScrollViewController set up
    BTGlassScrollViewController *glassScrollViewController = [[BTGlassScrollViewController alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"background%i",index%2?2:3]]];
    [glassScrollViewController setTitle:[NSString stringWithFormat:@"Title for #%i", index]];
    [glassScrollViewController setIndex:index];
    return glassScrollViewController;
}

@end
