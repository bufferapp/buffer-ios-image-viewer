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
    BFRBackLoadedImageSource *backloadedImage = [[BFRBackLoadedImageSource alloc] initWithInitialImage:[UIImage imageNamed:@"lowResImage"] hiResURL:[NSURL URLWithString:@"https://overflow.buffer.com/wp-content/uploads/2016/12/1-hByZ0VpJusdVwpZd-Z4-Zw.png"]];
    
    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[backloadedImage]];
    [self presentViewController:imageVC animated:YES completion:nil];
}

- (void)openImageViewerWithCompletionHandler {
    BFRBackLoadedImageSource *backloadedImage = [[BFRBackLoadedImageSource alloc] initWithInitialImage:[UIImage imageNamed:@"lowResImage"] hiResURL:[NSURL URLWithString:@"https://overflow.buffer.com/wp-content/uploads/2016/12/1-hByZ0VpJusdVwpZd-Z4-Zw.png"]];
    
    backloadedImage.onCompletion = ^(UIImage * _Nullable img, NSError * _Nullable error) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Download Done" message:[NSString stringWithFormat:@"Finished downloading hi res image.\nImage:%@\nError:%@", img, error] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *close = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:close];
        

        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        
        [topController presentViewController:alertVC animated:YES completion:nil];
    };
    
    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[backloadedImage]];
    [self presentViewController:imageVC animated:YES completion:nil];
}

@end
