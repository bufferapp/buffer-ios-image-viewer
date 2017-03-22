//
//  ThirdViewController.m
//  BFRImageViewer
//
//  Created by Jordan Morgan on 3/21/17.
//  Copyright © 2017 Andrew Yates. All rights reserved.
//

#import "ThirdViewController.h"
#import "BFRImageTransitionAnimator.h"
#import "BFRImageViewController.h"

@interface ThirdViewController () <UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) BFRImageTransitionAnimator *imageViewAnimator;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation ThirdViewController

- (instancetype) init {
    if (self = [super init]) {
        self.title = @"Custom Transition";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // To use the custom transition animation with BFRImageViewer
    // 1) Conform to <UIViewControllerTransitioningDelegate> on the presenting controller
    // 2) Implement the two delegate methods, as seen below
    // 3) Return an instance of BFRImageTransitionAnimator from both delegate methods
    // 4) When you present the controller, set its transitioningDelegate = presentingController (i.e. self)
    
    // Object to create all the animations
    self.imageViewAnimator = [BFRImageTransitionAnimator new];
    
    self.imageView = [UIImageView new];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.userInteractionEnabled = YES;
    [self.view addSubview:self.imageView];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://open.buffer.com/wp-content/uploads/2017/03/Moo.jpg"] completionHandler:^ (NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            if (data) {
                self.imageView.image = [UIImage imageWithData:data];
                
                UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openImageViewerWithTransition)];
                [self.imageView addGestureRecognizer:gestureRecognizer];
            }
        });
    }] resume];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.imageView.frame = CGRectMake(0, 100, self.view.frame.size.width, 300);
}

- (void)openImageViewerWithTransition {
    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[self.imageView.image]];
    
    // This triggers the custom animation, if you forget this, no custom transition occurs
    imageVC.transitioningDelegate = self;
    // This ensures we hide the first image and then show it when the transition is done
    imageVC.customTransitionEnabled = YES;
    
    [self presentViewController:imageVC animated:YES completion:nil];
}

// If you want the custom transition, implement these two delegate methods
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.imageViewAnimator.animatedImageView = self.imageView;
    return self.imageViewAnimator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.imageViewAnimator.animatedImageView = self.imageView;
    return self.imageViewAnimator;
}

@end
