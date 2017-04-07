//
//  FourthViewController.m
//  BFRImageViewer
//
//  Created by Jordan Morgan on 4/6/17.
//  Copyright © 2017 Andrew Yates. All rights reserved.
//

#import "FourthViewController.h"
#import "BFRBackLoadedImageSource.h"
#import "BFRImageViewController.h"

@interface FourthViewController ()

@end

@implementation FourthViewController

- (instancetype) init {
    if (self = [super init]) {
        self.title = @"Backloading";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn addTarget:self action:@selector(openImageViewer) forControlEvents:UIControlEventTouchUpInside];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn setTitle:@"Backload URL Image" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [btn.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}

- (void)openImageViewer {
    BFRBackLoadedImageSource *backloadedImage = [[BFRBackLoadedImageSource alloc] initWithInitialImage:[UIImage imageNamed:@"lowResImage"] hiResURL:[NSURL URLWithString:@"https://overflow.buffer.com/wp-content/uploads/2016/12/1-hByZ0VpJusdVwpZd-Z4-Zw.png"]];
    
    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[backloadedImage]];
    [self presentViewController:imageVC animated:YES completion:nil];
}

@end
