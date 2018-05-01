//
//  BFRBackLoadedImageSource.m
//  BFRImageViewer
//
//  Created by Jordan Morgan on 4/6/17.
//  Copyright © 2017 Andrew Yates. All rights reserved.
//

#import "BFRBackLoadedImageSource.h"
#import "BFRImageViewerConstants.h"
#import <UIKit/UIKit.h>
#import <PINRemoteImage/PINRemoteImage.h>
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>

@interface BFRBackLoadedImageSource()

/*! The high fidelity image that will be loaded in the background and then shown once it's downloaded. */
@property (strong, nonatomic, nonnull) NSURL *url;

/*! The image that will show initially. */
@property (strong, nonatomic, readwrite, nonnull) UIImage *image;

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
            if (self.onCompletion != nil) {
                if (result.image) {
                    self.onCompletion(result.image, nil);
                } else {
                    NSLog(@"BFRImageViewer: Unable to load high resolution photo via backloading.");
                    NSError *downloadError = [NSError errorWithDomain:HI_RES_IMG_ERROR_DOMAIN
                                                                 code:HI_RES_IMG_ERROR_CODE
                                                             userInfo:@{NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Failed to download an image for high resolution url %@", self.url.absoluteString]}];
                    self.onCompletion(nil, downloadError);
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_HI_RES_IMG_DOWNLOADED object:result.image];
        });
    }];
}

@end
