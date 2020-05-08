//
//  FifthViewController.m
//  BFRImageViewer
//
//  Created by Omer Emre Aslan on 18.10.2017.
//  Copyright © 2017 Andrew Yates. All rights reserved.
//

#import <Photos/Photos.h>
#import "FifthViewController.h"
#import "BFRImageViewController.h"

@interface FifthViewController () <UIViewControllerPreviewingDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation FifthViewController

#pragma mark - Initializer and Lifecycle

- (instancetype) init {
    if (self = [super init]) {
        self.title = @"Live Photo";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self check3DTouch];
    [self addButtonsToView];
}

#pragma mark - 3D Touch

- (void)check3DTouch {
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        return [self imageViewControllerForLivePhotoDisableAutoplay:NO];
    } else {
        [self showAuthorizationAlertViewControllerAnimated:YES];
        return nil;
    }
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self presentViewController:viewControllerToCommit animated:YES completion:nil];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self check3DTouch];
    }
}

#pragma mark - Misc

- (void)addButtonsToView {
    UIButton *openImageFromURL = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    openImageFromURL.translatesAutoresizingMaskIntoConstraints = NO;
    [openImageFromURL setTitle:@"Open 1st Found Live Photo" forState:UIControlStateNormal];
    [openImageFromURL addTarget:self
                         action:@selector(openImage:)
               forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openImageFromURL];
    [openImageFromURL.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [openImageFromURL.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    
    UIButton *openImagePicker = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    openImagePicker.translatesAutoresizingMaskIntoConstraints = NO;
    [openImagePicker setTitle:@"Select Image" forState:UIControlStateNormal];
    [openImagePicker addTarget:self
                         action:@selector(presentImagePicker)
               forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openImagePicker];
    [openImagePicker.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [openImagePicker.topAnchor constraintEqualToAnchor:openImageFromURL.bottomAnchor].active = YES;
}

#pragma mark - Image Picker

- (void)presentImagePicker {
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[@"public.image"];
    picker.delegate = self;
    [self.tabBarController presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        if (info[UIImagePickerControllerPHAsset]) {
            BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[info[UIImagePickerControllerPHAsset]]];
            
            [self presentViewController:imageVC
                               animated:YES
                             completion:nil];
        }
    }];
}

#pragma mark - Actions

- (void)openImage:(UIButton *)sender {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        BFRImageViewController *imageViewController = [self
                                                       imageViewControllerForLivePhotoDisableAutoplay:YES];
        [self presentViewController:imageViewController
                           animated:YES
                         completion:nil];
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                BFRImageViewController *imageViewController = [self imageViewControllerForLivePhotoDisableAutoplay:YES];
                [self presentViewController:imageViewController
                                   animated:YES
                                 completion:nil];
            } else {
                [self showAuthorizationAlertViewControllerAnimated:YES];
            }
        }];
    }
    
}

- (void)showAuthorizationAlertViewControllerAnimated:(BOOL)isAnimated {
    UIAlertController *controller = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"Authorization Failed!", nil)
                                     message:NSLocalizedString(@"In order to access live photo feature, please allow authorization on Settings.", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Close", nil)
                                  style:UIAlertActionStyleDefault
                                  handler:nil];
    [controller addAction:closeAction];
    
    [self presentViewController:controller
                       animated:isAnimated
                     completion:nil];
}

- (BFRImageViewController *)imageViewControllerForLivePhotoDisableAutoplay:(BOOL)shouldDisableAutoPlay {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaSubtype == %d", PHAssetMediaSubtypePhotoLive];
    options.includeAllBurstAssets = NO;
    PHFetchResult *allLivePhotos = [PHAsset fetchAssetsWithOptions:options];
    
    NSMutableArray *livePhotosToShow = [NSMutableArray new];
    
    if (allLivePhotos.count > 0) {
        NSInteger maxResults = 4;
        NSInteger currentFetchCount = 0;
        
        for (PHFetchResult *result in allLivePhotos) {
            if (currentFetchCount == maxResults) {
                break;
            }
            
            [livePhotosToShow addObject:result];
            currentFetchCount++;
        }
        
        BFRImageViewController *viewController = [[BFRImageViewController alloc]
                                                  initWithImageSource:[livePhotosToShow copy]];
        viewController.disableAutoplayForLivePhoto = shouldDisableAutoPlay;
        return viewController;
    } else {
        UIAlertController *controller = [UIAlertController
                                         alertControllerWithTitle:@"No Live Photos"
                                         message:@"There doesn't appear to be any live photos on your device."
                                         preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction
                                      actionWithTitle:NSLocalizedString(@"Close", nil)
                                      style:UIAlertActionStyleDefault
                                      handler:nil];
        [controller addAction:closeAction];
        
        [self presentViewController:controller
                           animated:YES
                         completion:nil];
        
        return nil;
    }
}

@end
