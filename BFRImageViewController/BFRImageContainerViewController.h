//
//  BFRImageContainerViewController.h
//  Buffer
//
//  Created by Jordan Morgan on 11/10/15.
//
//

#import <UIKit/UIKit.h>

/*! This class holds an image to view, if you need an image viewer alloc @C BFRImageViewController instead. This class isn't meant to instanitated outside of it. */
@interface BFRImageContainerViewController : UIViewController

/*! Source of the image, which should either be @c NSURL or @c UIIimage. */
@property (strong, nonatomic, nonnull) id imgSrc;

/*! This will determine whether to change certain behaviors for 3D touch considerations based on its value. */
@property (nonatomic, getter=isBeingUsedFor3DTouch) BOOL usedFor3DTouch;

/*! A helper integer to simplify using this view controller inside a @c UIPagerViewController when swiping between views. */
@property (nonatomic, assign) NSUInteger pageIndex;

/*! Assigning YES to this property will make the background transparent. You typically don't set this property yourself, instead, the value is derived from the containing @c BFRImageViewController instance. */
@property (nonatomic, getter=isUsingTransparentBackground) BOOL useTransparentBackground;

/*! Assigning YES to this property will disable long pressing media to present the activity view controller. You typically don't set this property yourself, instead, the value is derived from the containing @c BFRImageViewController instance. */
@property (nonatomic, getter=shouldDisableSharingLongPress) BOOL disableSharingLongPress;

/*! If there is more than one image in the containing @c BFRImageViewController - this property is set to YES to make swiping from image to image easier. */
@property (nonatomic, getter=shouldDisableHorizontalDrag) BOOL disableHorizontalDrag;

/*! Assigning YES to this property will disable autoplay for live photos when it used with 3DTouch peek feature */
@property (nonatomic, getter=shouldDisableAutoplayForLivePhoto) BOOL disableAutoplayForLivePhoto;

@end
