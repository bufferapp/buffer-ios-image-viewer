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
@property (weak, nonatomic) UIImageView *animatedImageView;

@end
