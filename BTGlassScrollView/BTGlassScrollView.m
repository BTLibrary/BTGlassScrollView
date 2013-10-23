//
//  BTGlassScrollView.m
//  BTGlassScrollViewExample
//
//  Created by Byte on 10/18/13.
//  Copyright (c) 2013 Byte. All rights reserved.
//

#import "BTGlassScrollView.h"

@implementation BTGlassScrollView
{
    UIScrollView *_backgroundScrollView;
    UIView *_constraitView;
    UIImageView *_backgroundImageView;
    UIImageView *_blurredBackgroundImageView;
    
    CALayer *_topShadowLayer;
    CALayer *_botShadowLayer;
    
    UIView *_foregroundContainerView; // for masking
    UIImageView *_topMaskImageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame BackgroundImage:(UIImage *)backgroundImage blurredImage:(UIImage *)blurredImage viewDistanceFromBottom:(CGFloat)viewDistanceFromBottom foregroundView:(UIView *)foregroundView
{
    self = [super initWithFrame:frame];
    if (self) {
        //initialize values
        _backgroundImage = backgroundImage;
        if (blurredImage) {
            _blurredBackgroundImage = backgroundImage;
        }else{
            _blurredBackgroundImage = [backgroundImage applyBlurWithRadius:DEFAULT_BLUR_RADIUS tintColor:DEFAULT_BLUR_TINT_COLOR saturationDeltaFactor:DEFAULT_BLUR_DELTA_FACTOR maskImage:nil];
        }
        _viewDistanceFromBottom = viewDistanceFromBottom;
        _foregroundView = foregroundView;
        
        //autoresize
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        
        //create views
        [self createBackgroundView];
        [self createForegroundView];
        [self createTopShadow];
        [self createBottomShadow];
    }
    return self;
}

- (void)scrollHorizontalRatio:(CGFloat)ratio
{
    [_backgroundScrollView setContentOffset:CGPointMake(DEFAULT_MAX_BACKGROUND_MOVEMENT_HORIZONTAL + ratio * DEFAULT_MAX_BACKGROUND_MOVEMENT_HORIZONTAL, _backgroundScrollView.contentOffset.y)];
}

- (void)scrollVerticallyToOffset:(CGFloat)offsetY
{
    [_foregroundScrollView setContentOffset:CGPointMake(_foregroundScrollView.contentOffset.x, offsetY)];
}

#pragma mark - Setters
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    //work background
    CGRect bound = CGRectOffset(frame, -frame.origin.x, -frame.origin.y);
    
    [_backgroundScrollView setFrame:bound];
    [_backgroundScrollView setContentSize:CGSizeMake(bound.size.width + DEFAULT_MAX_BACKGROUND_MOVEMENT_HORIZONTAL, bound.size.height + DEFAULT_MAX_BACKGROUND_MOVEMENT_VERTICAL)];
    [_backgroundScrollView setContentOffset:CGPointMake(DEFAULT_MAX_BACKGROUND_MOVEMENT_HORIZONTAL, 0)];
    [_constraitView setFrame:CGRectMake(0, 0, frame.size.width + DEFAULT_MAX_BACKGROUND_MOVEMENT_HORIZONTAL, frame.size.height + DEFAULT_MAX_BACKGROUND_MOVEMENT_VERTICAL)];
    
    //foreground
    [_foregroundContainerView setFrame:bound];
    [_foregroundScrollView setFrame:bound];
    [_foregroundView setFrame:CGRectOffset(_foregroundView.bounds, (_foregroundScrollView.frame.size.width - _foregroundView.bounds.size.width)/2, _foregroundScrollView.frame.size.height - _foregroundScrollView.contentInset.top - _viewDistanceFromBottom)];
    [_foregroundScrollView setContentSize:CGSizeMake(bound.size.width, _foregroundView.frame.origin.y + _foregroundView.frame.size.height)];
    
    //shadows
    //[self createTopShadow];
    [_topShadowLayer setFrame:CGRectMake(0, 0, frame.size.width, _foregroundScrollView.contentInset.top + DEFAULT_TOP_FADING_HEIGHT_HALF)];
    [_botShadowLayer setFrame:CGRectMake(0, bound.size.height - _viewDistanceFromBottom, bound.size.width, bound.size.height)];//CGRectOffset(_botShadowLayer.bounds, 0, frame.size.height - _viewDistanceFromBottom)];

    if (_delegate && [_delegate respondsToSelector:@selector(glassScrollView:didChangedToFrame:)]) {
        [_delegate glassScrollView:self didChangedToFrame:bound];
    }
}

- (void)setTopLayoutGuideLength:(CGFloat)topLayoutGuideLength
{
    if (topLayoutGuideLength == 0) {
        return;
    }
    
    //set inset
    [_foregroundScrollView setContentInset:UIEdgeInsetsMake(topLayoutGuideLength, 0, 0, 0)];
    
    //reposition
    [_foregroundView setFrame:CGRectOffset(_foregroundView.bounds, (_foregroundScrollView.frame.size.width - _foregroundView.bounds.size.width)/2, _foregroundScrollView.frame.size.height - _foregroundScrollView.contentInset.top - _viewDistanceFromBottom)];
    
    //resize contentSize
    [_foregroundScrollView setContentSize:CGSizeMake(self.frame.size.width, _foregroundView.frame.origin.y + _foregroundView.frame.size.height)];
    
    //reset the offset
    [_foregroundScrollView setContentOffset:CGPointMake(0, - _foregroundScrollView.contentInset.top)];
    
    //adding new mask
    _foregroundContainerView.layer.mask = [self createTopMaskWithSize:CGSizeMake(_foregroundContainerView.frame.size.width, _foregroundContainerView.frame.size.height) startFadeAt:_foregroundScrollView.contentInset.top - DEFAULT_TOP_FADING_HEIGHT_HALF endAt:_foregroundScrollView.contentInset.top + DEFAULT_TOP_FADING_HEIGHT_HALF topColor:[UIColor colorWithWhite:1.0 alpha:0.0] botColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    
    //recreate shadow
    [self createTopShadow];
}

- (void)setViewDistanceFromBottom:(CGFloat)viewDistanceFromBottom
{
#warning might cause infiniteloop
    _viewDistanceFromBottom = viewDistanceFromBottom;
    
    [_foregroundView setFrame:CGRectOffset(_foregroundView.bounds, (_foregroundScrollView.frame.size.width - _foregroundView.bounds.size.width)/2, _foregroundScrollView.frame.size.height - _foregroundScrollView.contentInset.top - _viewDistanceFromBottom)];
    [_foregroundScrollView setContentSize:CGSizeMake(self.frame.size.width, _foregroundView.frame.origin.y + _foregroundView.frame.size.height)];
    
    //shadows
    [_botShadowLayer setFrame:CGRectOffset(_botShadowLayer.bounds, 0, self.frame.size.height - _viewDistanceFromBottom)];
}

#pragma mark - Views creation
#pragma mark ScrollViews

- (void)createBackgroundView
{
    //background
    _backgroundScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    [_backgroundScrollView setUserInteractionEnabled:NO];
    [_backgroundScrollView setContentSize:CGSizeMake(self.frame.size.width + 2*DEFAULT_MAX_BACKGROUND_MOVEMENT_HORIZONTAL, self.frame.size.height + DEFAULT_MAX_BACKGROUND_MOVEMENT_VERTICAL)];
    [self addSubview:_backgroundScrollView];
    
    _constraitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width + 2*DEFAULT_MAX_BACKGROUND_MOVEMENT_HORIZONTAL, self.frame.size.height + DEFAULT_MAX_BACKGROUND_MOVEMENT_VERTICAL)];
    [_backgroundScrollView addSubview:_constraitView];
    
    _backgroundImageView = [[UIImageView alloc] initWithImage:_backgroundImage];
    [_backgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_constraitView addSubview:_backgroundImageView];
    _blurredBackgroundImageView = [[UIImageView alloc] initWithImage:_blurredBackgroundImage];
    [_blurredBackgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_blurredBackgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_blurredBackgroundImageView setAlpha:0];
    [_constraitView addSubview:_blurredBackgroundImageView];
    
    [_constraitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImageView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_backgroundImageView)]];
    [_constraitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImageView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_backgroundImageView)]];
    [_constraitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_blurredBackgroundImageView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_blurredBackgroundImageView)]];
    [_constraitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_blurredBackgroundImageView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_blurredBackgroundImageView)]];
}



- (void)createForegroundView
{
    _foregroundContainerView = [[UIView alloc] initWithFrame:self.frame];
    [self addSubview:_foregroundContainerView];
    
    _foregroundScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    [_foregroundScrollView setDelegate:self];
    [_foregroundScrollView setShowsVerticalScrollIndicator:NO];
    [_foregroundScrollView setShowsHorizontalScrollIndicator:NO];
    [_foregroundContainerView addSubview:_foregroundScrollView];
    
    UITapGestureRecognizer *_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foregroundTapped:)];
    [_foregroundScrollView addGestureRecognizer:_tapRecognizer];
    
    
    [_foregroundView setFrame:CGRectOffset(_foregroundView.bounds, (_foregroundScrollView.frame.size.width - _foregroundView.bounds.size.width)/2, _foregroundScrollView.frame.size.height - _viewDistanceFromBottom)];
    [_foregroundScrollView addSubview:_foregroundView];
    
    [_foregroundScrollView setContentSize:CGSizeMake(self.frame.size.width, _foregroundView.frame.origin.y + _foregroundView.frame.size.height)];
}

#pragma mark Shadow and Mask Layer
- (CALayer *)createTopMaskWithSize:(CGSize)size startFadeAt:(CGFloat)top endAt:(CGFloat)bottom topColor:(UIColor *)topColor botColor:(UIColor *)botColor;
{
    top = top/size.height;
    bottom = bottom/size.height;
    
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    maskLayer.anchorPoint = CGPointZero;
    maskLayer.startPoint = CGPointMake(0.5f, 0.0f);
    maskLayer.endPoint = CGPointMake(0.5f, 1.0f);
    
    //an array of colors that dictatates the gradient(s)
    maskLayer.colors = @[(id)topColor.CGColor, (id)topColor.CGColor, (id)botColor.CGColor, (id)botColor.CGColor];
    maskLayer.locations = @[@0.0, @(top), @(bottom), @1.0f];
    maskLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    return maskLayer;
}

- (void)createTopShadow
{
    //changing the top shadow
    [_topShadowLayer removeFromSuperlayer];
    _topShadowLayer = [self createTopMaskWithSize:CGSizeMake(_foregroundContainerView.frame.size.width, _foregroundScrollView.contentInset.top + DEFAULT_TOP_FADING_HEIGHT_HALF) startFadeAt:_foregroundScrollView.contentInset.top - DEFAULT_TOP_FADING_HEIGHT_HALF endAt:_foregroundScrollView.contentInset.top + DEFAULT_TOP_FADING_HEIGHT_HALF topColor:[UIColor colorWithWhite:0 alpha:.15] botColor:[UIColor colorWithWhite:0 alpha:0]];
    [self.layer insertSublayer:_topShadowLayer below:_foregroundContainerView.layer];
}
- (void)createBottomShadow
{
    [_botShadowLayer removeFromSuperlayer];
    _botShadowLayer = [self createTopMaskWithSize:CGSizeMake(self.frame.size.width,_viewDistanceFromBottom) startFadeAt:0 endAt:_viewDistanceFromBottom topColor:[UIColor colorWithWhite:0 alpha:0] botColor:[UIColor colorWithWhite:0 alpha:.8]];
    [_botShadowLayer setFrame:CGRectOffset(_botShadowLayer.bounds, 0, self.frame.size.height - _viewDistanceFromBottom)];
    [self.layer insertSublayer:_botShadowLayer below:_foregroundContainerView.layer];
}


#pragma mark - Button
- (void)foregroundTapped:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint tappedPoint = [tapRecognizer locationInView:_foregroundScrollView];
    NSLog(@"%f", tappedPoint.y);
    if (tappedPoint.y < _foregroundScrollView.frame.size.height) {
        CGFloat ratio = _foregroundScrollView.contentOffset.y == -_foregroundScrollView.contentInset.top? 1:0;
        [_foregroundScrollView setContentOffset:CGPointMake(0, ratio * _foregroundView.frame.origin.y - _foregroundScrollView.contentInset.top) animated:YES];
    }
}

#pragma mark - Delegate
#pragma mark UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //translate into ratio to height
    CGFloat ratio = (scrollView.contentOffset.y + _foregroundScrollView.contentInset.top)/(_foregroundScrollView.frame.size.height - _foregroundScrollView.contentInset.top - _viewDistanceFromBottom);
    ratio = ratio<0?0:ratio;
    ratio = ratio>1?1:ratio;
    
    //set background scroll
    [_backgroundScrollView setContentOffset:CGPointMake(DEFAULT_MAX_BACKGROUND_MOVEMENT_HORIZONTAL, ratio * DEFAULT_MAX_BACKGROUND_MOVEMENT_VERTICAL)];
    
    //set alpha
    [_blurredBackgroundImageView setAlpha:ratio];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    CGPoint point = *targetContentOffset;
    CGFloat ratio = (point.y + _foregroundScrollView.contentInset.top)/(_foregroundScrollView.frame.size.height - _foregroundScrollView.contentInset.top - _viewDistanceFromBottom);
    
    //it cannot be inbetween 0 to 1 so if it is >.5 it is one, otherwise 0
    if (ratio > 0 && ratio < 1) {
        if (velocity.y == 0) {
            ratio = ratio > .5?1:0;
        }else if(velocity.y > 0){
            ratio = ratio > .1?1:0;
        }else{
            ratio = ratio > .9?1:0;
        }
        targetContentOffset->y = ratio * _foregroundView.frame.origin.y - _foregroundScrollView.contentInset.top;
    }
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
