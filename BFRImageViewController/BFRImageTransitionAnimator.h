//
//  BFRImageTransitionAnimator.h
//  BFRImageViewer
//
//  Created by Jordan Morgan on 3/21/17.
//  Copyright © 2017 Andrew Yates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BFRImageTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

/*! This is the image that will animate during the transition. A copy of it will be made, and this is just used for reference. This must be set before the animation begins. */
@property (strong, nonatomic) UIImage *animatedImage;

/*! The frame where the animated image began at, housed in the presenting view controller. When dismissed, the image will animate back to this @t CGRect. */
@property (nonatomic) CGRect imageOriginFrame;

/*! Set this to the content mode of the containing view that's holding the image you're animating, otherwise, the frames will look off. */
@property (nonatomic) UIViewContentMode desiredContentMode;

@end
