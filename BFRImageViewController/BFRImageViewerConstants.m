//
//  BFRImageViewerConstants.m
//  BFRImageViewer
//
//  Created by Jordan Morgan on 10/5/17.
//  Copyright © 2017 Andrew Yates. All rights reserved.
//

#import "BFRImageViewerConstants.h"

@implementation BFRImageViewerConstants

NSString * const NOTE_VC_POPPED = @"ViewControllerPopped";
NSString * const NOTE_HI_RES_IMG_DOWNLOADED = @"HiResDownloadDone";
NSString * const NOTE_VC_SHOULD_DISMISS = @"DismissUI";
NSString * const NOTE_VC_SHOULD_DISMISS_FROM_DRAGGING = @"DimissUIFromDraggingGesture";
NSString * const NOTE_VC_SHOULD_CANCEL_CUSTOM_TRANSITION = @"CancelCustomDismissalTransition";
NSString * const NOTE_IMG_FAILED = @"ImageLoadingError";

NSString * const ERROR_TITLE = @"Whoops";
NSString * const ERROR_MESSAGE = @"Looks like we ran into an issue loading the image, sorry about that!";
NSString * const GENERAL_OK = @"Ok";
NSString * const HI_RES_IMG_ERROR_DOMAIN = @"com.bfrImageViewer.backLoadedImgSource";
NSInteger const HI_RES_IMG_ERROR_CODE = 44;

NSInteger const PARALLAX_EFFECT_WIDTH = 20;

@end
