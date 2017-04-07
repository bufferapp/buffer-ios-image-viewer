//
//  BFRImageTransitionAnimator.h
//  BFRImageViewer
//
//  Created by Jordan Morgan on 3/21/17.
//  Copyright © 2017 Andrew Yates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static const CGFloat DEFAULT_ANIMATION_DURATION = 0.23f;

@interface BFRImageTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

/*! The view that houses the @c UIImage being aniamted. Typically will be a @c UIImageView. If set, this will be hidden during the animation which looks nicer. */
@property (strong, nonatomic, nonnull) UIView *animatedImageContainer;

/*! This is the image that will animate during the transition. A copy of it will be made, and this is just used for reference. This must be set before the animation begins. */
@property (strong, nonatomic, nonnull) UIImage *animatedImage;

/*! The frame where the animated image began at, housed in the presenting view controller. When dismissed, the image will animate back to this @t CGRect. */
@property (nonatomic) CGRect imageOriginFrame;

/*! Set this to the content mode of the containing view that's holding the image you're animating, otherwise, the frames might look off. */
@property (nonatomic) UIViewContentMode desiredContentMode;

/*! The duration of the animation for the custom transition. By default, this is set to DEFAULT_ANIMATION_DURATION. */
@property (nonatomic) CGFloat animationDuration;

@end
