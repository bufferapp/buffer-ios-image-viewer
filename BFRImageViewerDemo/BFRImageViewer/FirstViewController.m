//
//  FirstViewController.m
//  BFRImageViewer
//
//  Created by Andrew Yates on 20/11/2015.
//  Copyright © 2015 Andrew Yates. All rights reserved.
//

#import "FirstViewController.h"
#import "BFRImageViewController.h"

@interface FirstViewController ()
@property (strong, nonatomic) NSURL *imgURL;
@end

@implementation FirstViewController

- (instancetype) init {
    if (self = [super init]) {
        self.title = @"Single GIF";
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self addImageButtonToView];
    
    self.imgURL = [NSURL URLWithString:@"https://media0.giphy.com/media/huJmPXfeir5JlpPAx0/200.gif"];
}

- (void)openImage {
    //Here, the image source could be an array containing/a mix of URL strings, NSURLs, PHAssets, or UIImages
    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[self.imgURL]];    
    [self presentViewController:imageVC animated:YES completion:nil];
}

#pragma mark - Misc 
- (void)addImageButtonToView {
    UIButton *openImageFromURL = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    openImageFromURL.translatesAutoresizingMaskIntoConstraints = NO;
    [openImageFromURL setTitle:@"Open Image" forState:UIControlStateNormal];
    [openImageFromURL addTarget:self action:@selector(openImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openImageFromURL];
    [openImageFromURL.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [openImageFromURL.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}
@end
