//
//  BFRImageTransitionAnimator.m
//  BFRImageViewer
//
//  Created by Jordan Morgan on 3/21/17.
//  Copyright © 2017 Andrew Yates. All rights reserved.
//

#import "BFRImageTransitionAnimator.h"

@interface BFRImageTransitionAnimator()

/*! Tracks whether the class should stage the animation for presentation or dismissal. */
@property (nonatomic, getter=isPresenting) BOOL presenting;

/*! If the user drags the image away to close the image viewer, then this forces the "basic" view controller dismissal animation to run, which is a cross dissolve. Of note, since this instance may not be deallocated between presentations, this flag is effectively reset at the start of performPresentationAnimation:, and will be mutated accordingly there after. */
@property (nonatomic, getter=shouldDismissWithoutCustomTransition) BOOL dismissWithoutCustomTransition;

/*! Represents the device orientation state when the controller is presented. If that changes when dismissal occurs, the custom transition animation isn't used. This is because it can be quite difficult for consumers to get the correct frame that the image should animate back to upon rotation. This may be supported in the future. */
@property (nonatomic) UIDeviceOrientation presentedDeviceOrientation;

@end

@implementation BFRImageTransitionAnimator

#pragma mark - Initialization
- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.presenting = YES;
        self.desiredContentMode = UIViewContentModeScaleAspectFill;
        self.animationDuration = DEFAULT_ANIMATION_DURATION;
        self.dismissWithoutCustomTransition = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCancelCustomTransitionNotification:) name:@"CancelCustomDismissalTransition" object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleCancelCustomTransitionNotification:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[NSNumber class]]) {
        self.dismissWithoutCustomTransition = ((NSNumber *)notification.object).boolValue;
    }
}

#pragma mark - Utils
- (UIImageView *)temporaryImageView {
    if (self.animatedImage == nil) return nil;
    
    // Animating a view of the presenting controller isn't a great idea, so we make a temporary image view instead
    // And leave the originial one alone.
    UIImageView *temporaryAnimatedImageView = [[UIImageView alloc] initWithImage:self.animatedImage];
    temporaryAnimatedImageView.frame = self.isPresenting ? self.imageOriginFrame : CGRectZero;
    temporaryAnimatedImageView.contentMode = self.desiredContentMode;
    temporaryAnimatedImageView.layer.masksToBounds = YES;
    
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
    return self.animationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.presenting) {
        [self performPresentationAnimation:transitionContext];
    } else {
        [self performDismissingAnimation:transitionContext];
    }
}

- (void)performPresentationAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.dismissWithoutCustomTransition = NO;
    self.presentedDeviceOrientation = [[UIDevice currentDevice] orientation];
    
    UIView *animationContainerView = transitionContext.containerView;
    UIView *destinationView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    destinationView.alpha = 0.0f;
    
    // Hide the first image from showing during the animation
    destinationView.subviews.firstObject.hidden = YES;
    self.animatedImageContainer.alpha = 0.0f;
    
    UIImageView *temporaryAnimatedImageView = [self temporaryImageView];
    
    [animationContainerView addSubview:destinationView];
    [animationContainerView addSubview:temporaryAnimatedImageView];
    
    CGRect animatedImageViewDestination = [self imageFinalFrameDestinationForImageView:temporaryAnimatedImageView inView:animationContainerView];
    
    [UIView animateWithDuration:self.animationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^ {
        temporaryAnimatedImageView.frame = animatedImageViewDestination;
        destinationView.alpha = 1.0f;
    } completion:^ (BOOL done) {
        [transitionContext completeTransition:YES];
        self.presenting = !self.isPresenting;
        destinationView.subviews.firstObject.hidden = NO;
        [temporaryAnimatedImageView removeFromSuperview];
    }];
}

- (void)performDismissingAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.shouldDismissWithoutCustomTransition == NO) {
        // If we rotated - we'll forgo the custom dismissal transition animation
        // If the image was drug away - this will already be NO, so there is no need to possibly overwrite it
        self.dismissWithoutCustomTransition = (self.presentedDeviceOrientation != [UIDevice currentDevice].orientation);
    }
    
    UIView *animationContainerView = transitionContext.containerView;
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *destinationView = [transitionContext viewForKey:UITransitionContextToViewKey];
    destinationView.alpha = 0.0f;
    destinationView.frame = animationContainerView.frame;
    
    // Hide the first image from showing during the animation, and the original image
    fromView.subviews.firstObject.hidden = YES;
    UIImageView *temporaryAnimatedImageView = [self temporaryImageView];
    
    [animationContainerView addSubview:destinationView];
    
    if (self.shouldDismissWithoutCustomTransition == NO) {
         [animationContainerView addSubview:temporaryAnimatedImageView];
    } else {
        self.animatedImageContainer.alpha = 1.0f;
    }
    
    temporaryAnimatedImageView.frame = [self imageFinalFrameDestinationForImageView:temporaryAnimatedImageView inView:animationContainerView];
    
    [UIView animateWithDuration:self.animationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^ {
        if (self.shouldDismissWithoutCustomTransition == NO) {
            temporaryAnimatedImageView.frame = self.imageOriginFrame;
        }
        destinationView.alpha = 1.0f;
    } completion:^ (BOOL done) {
        [transitionContext completeTransition:YES];
        self.presenting = !self.isPresenting;
        self.animatedImageContainer.alpha = 1.0f;
        [temporaryAnimatedImageView removeFromSuperview];
    }];
}

#pragma mark - Transitioning Delegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

@end
