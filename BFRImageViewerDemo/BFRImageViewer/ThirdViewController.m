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

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    //This triggers the custom animation, if you forget this, no custom transition occurs
    imageVC.transitioningDelegate = self;
    
    [self presentViewController:imageVC animated:YES completion:nil];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.imageViewAnimator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.imageViewAnimator;
}

@end
