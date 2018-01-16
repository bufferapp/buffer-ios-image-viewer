//
//  BFRImageViewerConstants.h
//  BFRImageViewer
//
//  Created by Jordan Morgan on 10/5/17.
//  Copyright © 2017 Andrew Yates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFRImageViewerConstants : NSObject

// Notifications
extern NSString * const NOTE_VC_POPPED;
extern NSString * const NOTE_HI_RES_IMG_DOWNLOADED;
extern NSString * const NOTE_VC_SHOULD_DISMISS;
extern NSString * const NOTE_VC_SHOULD_DISMISS_FROM_DRAGGING;
extern NSString * const NOTE_VC_SHOULD_CANCEL_CUSTOM_TRANSITION;
extern NSString * const NOTE_IMG_FAILED;

// NSError
extern NSString * const ERROR_TITLE;
extern NSString * const ERROR_MESSAGE;
extern NSString * const GENERAL_OK;
extern NSString * const HI_RES_IMG_ERROR_DOMAIN;
extern NSInteger const HI_RES_IMG_ERROR_CODE;

// Misc
extern NSInteger const PARALLAX_EFFECT_WIDTH;

@end
