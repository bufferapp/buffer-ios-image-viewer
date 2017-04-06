//
//  BFRBackLoadedImageSource.m
//  BFRImageViewer
//
//  Created by Jordan Morgan on 4/6/17.
//  Copyright © 2017 Andrew Yates. All rights reserved.
//

#import "BFRBackLoadedImageSource.h"
#import <UIKit/UIKit.h>
#import <PINRemoteImage/PINRemoteImage.h>
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>

@interface BFRBackLoadedImageSource()

/*! The high fidelity image that will be loaded in the background and then shown once it's downloaded. */
@property (strong, nonatomic) NSURL *url;

/*! The image that will show initially. */
@property (strong, nonatomic) UIImage *image;

@end

@implementation BFRBackLoadedImageSource

#pragma mark - Initializers
- (instancetype)initWithInitialImage:(UIImage *)image hiResURL:(NSURL *)url {
    self = [super init];
    
    if (self) {
        self.image = image;
        self.url = url;
        
        [self loadHighFidelityImage];
    }
    
    return self;
}

#pragma mark - Backloading
- (void)loadHighFidelityImage {
    [[PINRemoteImageManager sharedImageManager] downloadImageWithURL:self.url options:PINRemoteImageManagerDisallowAlternateRepresentations progressDownload:nil completion:^(PINRemoteImageManagerResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.image) {
                self.image = result.image;
            } else {
                NSLog(@"BFRImageViewer: Failed to retrieve high fidelity image.");
            }
        });
    }];
}

@end
