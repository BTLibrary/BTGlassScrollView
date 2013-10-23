BTGlassScrollView
=================

This is a view for you to either use as-is or modify the source. The view comes loaded with the ability to:

1. Create a self contained view replicating the look and feel of one panel of Yahoo! Weather app
2. Blur the background image and/or transform them just the right amount without additional code form you
3. Customized the animation/blur/height/shadow/etc. with a chagne of a number in the header #define
4. Just work! like magic! 

**Background:**  
I have been a big fan of Yahoo! weather app. I highly respect the work they have done. I wanted to replicate and also generalize the approach for anyone to use and/or study. This was not associated with Yahoo! No source was lifted from Yahoo! So there will be a few subtle differences between BTGlassScrollView and Yahoo! weather app. For example, this view is built to stay under one navigation bar which in turns allows for "swipe to back" on iOS7.

**Implementation:**  
The view is a subclass of a UIView. It contains 2 scrollViews, background and foreground. backgroundScrollView consists of 2 imageviews, normal and blurred. The alpha of the blurred one changes as the background scrolls. And the background scrolls as the foreground scrolls (at a different rate). The foregroundScrollView consists of maskLayers (gradient) and the foregroundView (which is whatever you want it to be). Between foreground and background, 2 shadowsLayer is added on the top and bottom to give a better readability.

**How to use (Simple Version):**

1. Import `BTGlassScrollView.h`  
2. Create an instance of glassScrollViewwith `- (id)initWithFrame:(CGRect)frame BackgroundImage:(UIImage *)backgroundImage blurredImage:(UIImage *)blurredImage viewDistanceFromBottom:(CGFloat)viewDistanceFromBottom foregroundView:(UIView *)foregroundView` and add it as subview to whereever you need it to be  
  2a. `backgroundImage` is essential, pick the right one makes all the difference  
  2b. `blurredImage` is not neccessary but you can provide your own customed one  
  2c. `viewDistanceFromBottom` is how much your foregroundView is visible from the bottom (like Yahoo! temperature)  
  2d. `foregroundView` is your info view  
4. Adjustment - due to generalization, you need to set the top padding to allow navigation bar/ status bar to get unmasked. Call `- (void)setTopLayoutGuideLength:(CGFloat)topLayoutGuideLength` where appropriate (Usually at `viewWillLayoutSubviews` in your view controller  

Please view example project to get the idea of how to implement. 

**How to implement Yahoo! like horizontal Scroll:**  
*To Be Added - it is in the example just not explained in words*  

**Note:**
The example provided are mix of 3 * 2 flavor. 3 ways to create viewController and 2 ways to implement the view. Uncomment the code in Appdelegate to see the different ways of creating ViewController and change the `#define SIMPLE_SAMPLE` to see the two ways of implementing

*3 ways to create viewController:*

1. plain vanilla viewController
2. viewController with NavigationController
3. viewController as a second screen of NavigationController

*2 ways to implement the view*

1. simple implementation
2. complex horizontal scroll implementation
