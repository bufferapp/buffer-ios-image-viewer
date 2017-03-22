//
//  BFRImageTransitionAnimator.m
//  BFRImageViewer
//
//  Created by Jordan Morgan on 3/21/17.
//  Copyright © 2017 Andrew Yates. All rights reserved.
//

#import "BFRImageTransitionAnimator.h"

static const CGFloat ANIMATION_DURATION = 0.25f;

@interface BFRImageTransitionAnimator()

@property (nonatomic) CGRect imageOriginFrame;
@property (nonatomic, getter=isPresenting) BOOL presenting;

@end

@implementation BFRImageTransitionAnimator

#pragma mark - Initialization
- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.presenting = YES;
    }
    
    return self;
}

#pragma mark - Utils
- (UIImageView *)temporaryImageView {
    if (self.animatedImageView == nil) return nil;
    
    // Animating a view of the presenting controller isn't a great idea, so we make a temporary image view instead
    // And leave the originial one alone.
    UIImageView *temporaryAnimatedImageView = [[UIImageView alloc] initWithImage:self.animatedImageView.image];
    temporaryAnimatedImageView.frame = self.isPresenting ? self.imageOriginFrame : CGRectZero;
    temporaryAnimatedImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    return temporaryAnimatedImageView;
}

- (CGRect)imageFinalFrameDestinationForImageView:(UIImageView *)imageView inView:(UIView *)view {
    // Set the aspect ratio of the image
    float hfactor = imageView.image.size.width / view.bounds.size.width;
    float vfactor = imageView.image.size.height / view.bounds.size.height;
    float factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = imageView.image.size.width / factor;
    float newHeight = imageView.image.size.height / factor;
    
    // Then figure out offset to center vertically or horizontally
    float leftOffset = (view.bounds.size.width - newWidth) / 2;
    float topOffset = (view.bounds.size.height - newHeight) / 2;
    
    // Reposition image view
    CGRect newRect = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
    
    // Check for any NaNs, which should get corrected in the next drawing cycle
    BOOL isInvalidRect = (isnan(leftOffset) || isnan(topOffset) || isnan(newWidth) || isnan(newHeight));
    return isInvalidRect ? CGRectZero : newRect;
}

#pragma mark - Animator delegate
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return ANIMATION_DURATION;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.presenting) {
        [self performPresentationAnimation:transitionContext];
    } else {
        [self performDismissingAnimation:transitionContext];
    }
}

- (void)performPresentationAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *animationContainerView = transitionContext.containerView;
    UIView *destinationView = [transitionContext viewForKey:UITransitionContextToViewKey];
    destinationView.alpha = 0.0f;
    
    // Used later to animate the image back
    self.imageOriginFrame = self.animatedImageView.frame;
    UIImageView *temporaryAnimatedImageView = [self temporaryImageView];
    
    [animationContainerView addSubview:destinationView];
    [animationContainerView addSubview:temporaryAnimatedImageView];
    
    CGRect animatedImageViewDestination = [self imageFinalFrameDestinationForImageView:temporaryAnimatedImageView inView:animationContainerView];
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^ {
        temporaryAnimatedImageView.frame = animatedImageViewDestination;
        destinationView.alpha = 1.0f;
    } completion:^ (BOOL done) {
        [transitionContext completeTransition:YES];
        self.presenting = !self.isPresenting;
        [temporaryAnimatedImageView removeFromSuperview];
    }];
}

- (void)performDismissingAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *animationContainerView = transitionContext.containerView;
    UIView *destinationView = [transitionContext viewForKey:UITransitionContextToViewKey];
    destinationView.alpha = 0.0f;
    
    UIImageView *temporaryAnimatedImageView = [self temporaryImageView];
    
    [animationContainerView addSubview:destinationView];
    [animationContainerView addSubview:temporaryAnimatedImageView];
    
    temporaryAnimatedImageView.frame = [self imageFinalFrameDestinationForImageView:temporaryAnimatedImageView inView:animationContainerView];
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^ {
        temporaryAnimatedImageView.frame = self.imageOriginFrame;
        destinationView.alpha = 1.0f;
    } completion:^ (BOOL done) {
        [transitionContext completeTransition:YES];
        self.presenting = !self.isPresenting;
        [temporaryAnimatedImageView removeFromSuperview];
    }];
}

@end
