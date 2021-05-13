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
    [btn.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-20].active = YES;
    
    
    UIButton *btnClosure = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnClosure addTarget:self action:@selector(openImageViewerWithCompletionHandler) forControlEvents:UIControlEventTouchUpInside];
    btnClosure.translatesAutoresizingMaskIntoConstraints = NO;
    [btnClosure setTitle:@"Backload URL Image + Completion Handler" forState:UIControlStateNormal];
    [self.view addSubview:btnClosure];
    [btnClosure.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [btnClosure.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:20].active = YES;
}

- (void)openImageViewer {
    BFRBackLoadedImageSource *backloadedImage = [[BFRBackLoadedImageSource alloc] initWithInitialImage:[UIImage imageNamed:@"lowResImage"] hiResURL:[NSURL URLWithString:@"https://images.unsplash.com/photo-1620910423680-80b93f872962?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1234&q=80"]];
    
    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[backloadedImage]];
    [self presentViewController:imageVC animated:YES completion:nil];
}

- (void)openImageViewerWithCompletionHandler {
    BFRBackLoadedImageSource *backloadedImage = [[BFRBackLoadedImageSource alloc] initWithInitialImage:[UIImage imageNamed:@"lowResImage"] hiResURL:[NSURL URLWithString:@"https://images.unsplash.com/photo-1620910423680-80b93f872962?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1234&q=80"]];
    
    backloadedImage.onCompletion = ^(UIImage * _Nullable img, NSError * _Nullable error) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Download Done" message:[NSString stringWithFormat:@"Finished downloading hi res image.\nImage:%@\nError:%@", img, error] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *close = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:close];
        
        UIViewController *topController = self.view.window.windowScene.windows.firstObject.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        
        [topController presentViewController:alertVC animated:YES completion:nil];
    };
    
    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[backloadedImage]];
    [self presentViewController:imageVC animated:YES completion:nil];
}

@end
