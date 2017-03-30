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

@interface ThirdViewController ()

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
    // 1) Have an instance of BFRImageTransitionAnimator around
    // 2) Set it's aniamtedImage, animatedImageContainer and imageOriginFrame. Optionally, set the desiredContentMode
    // 3) When you present the BFRImageViewController, set it's transitioningDelegate to your BFRImageTransitionAnimator instance.
    // You can see all of this in action in openImageViewerWithTransition below
    
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
    
    // This houses the image being animated, and will be hidden during the animations. Typically an image view
    self.imageViewAnimator.animatedImageContainer = self.imageView;
    // The image that will be animated
    self.imageViewAnimator.animatedImage = self.imageView.image;
    // The rect the image will aniamte to and from
    self.imageViewAnimator.imageOriginFrame = self.imageView.frame;
    // Optional - but you'll want this to match the view's content mode that the image is housed in
    self.imageViewAnimator.desiredContentMode = self.imageView.contentMode;

    // This triggers the custom animation, if you forget this, no custom transition occurs
    imageVC.transitioningDelegate = self.imageViewAnimator;
    
    [self presentViewController:imageVC animated:YES completion:nil];
}

@end
