//
//  SecondViewController.m
//  BFRImageViewer
//
//  Created by Andrew Yates on 20/11/2015.
//  Copyright © 2015 Andrew Yates. All rights reserved.
//

#import "SecondViewController.h"
#import "BFRImageViewer-Swift.h"

@interface SecondViewController () <UIViewControllerPreviewingDelegate>
@property (strong, nonatomic) NSArray *imgURLs;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *openImageFromURL = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    openImageFromURL.translatesAutoresizingMaskIntoConstraints = NO;
    [openImageFromURL setTitle:@"Open Images" forState:UIControlStateNormal];
    [openImageFromURL addTarget:self action:@selector(openImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openImageFromURL];
    [openImageFromURL.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [openImageFromURL.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self check3DTouch];
    }
    
    NSURL *url1 = [NSURL URLWithString:@"https://bufferblog-wpengine.netdna-ssl.com/wp-content/uploads/2015/10/social-media-icons-800x565.jpg"];
    NSURL *url2 = [NSURL URLWithString:@"https://open.buffer.com/wp-content/uploads/2015/11/new-journey-page.png"];
    NSURL *url3 = [NSURL URLWithString:@"http://i.imgur.com/XBnuETM.jpg"];
    self.imgURLs = @[url1, url2, url3];
}

- (void)didReceiveMemoryWarning {
    // Dispose of any resources that can be recreated.
}

- (void)openImage {
    BufferImageViewController *imageVC = [[BufferImageViewController alloc] initWithImageSource:self.imgURLs];
    [self presentViewController:imageVC animated:YES completion:nil];
}

#pragma mark - 3D Touch
- (void)check3DTouch {
    [self registerForPreviewingWithDelegate:self sourceView:self.view];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    return [[BufferImageViewController alloc] initWithImageSource:self.imgURLs];
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self presentViewController:viewControllerToCommit animated:YES completion:nil];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self check3DTouch];
    }
}
@end
