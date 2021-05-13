//
//  SecondViewController.m
//  BFRImageViewer
//
//  Created by Andrew Yates on 20/11/2015.
//  Copyright © 2015 Andrew Yates. All rights reserved.
//

#import "SecondViewController.h"
#import "BFRImageViewController.h"

@interface SecondViewController ()
@property (strong, nonatomic) NSArray *imgURLs;
@end

@implementation SecondViewController

- (instancetype) init {
    if (self = [super init]) {
        self.title = @"Multiple Images";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *openImageFromURL = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    openImageFromURL.translatesAutoresizingMaskIntoConstraints = NO;
    [openImageFromURL setTitle:@"Open Images" forState:UIControlStateNormal];
    [openImageFromURL addTarget:self action:@selector(openImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openImageFromURL];
    [openImageFromURL.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [openImageFromURL.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    
    NSURL *url1 = [NSURL URLWithString:@"https://images.unsplash.com/photo-1593642634443-44adaa06623a?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2425&q=80"];
    NSURL *url2 = [NSURL URLWithString:@"https://images.unsplash.com/photo-1519389950473-47ba0277781c?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=2700&q=80"];
    NSURL *url3 = [NSURL URLWithString:@"http://i.imgur.com/XBnuETM.jpg"];
    self.imgURLs = @[url1, url2, url3];
}

- (void)openImage {
    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:self.imgURLs];
    imageVC.startingIndex = 0; // Default
    [self presentViewController:imageVC animated:YES completion:nil];
}

@end
