//
//  BFRImageViewController.h
//  Buffer
//
//  Created by Jordan Morgan on 11/13/15.
//
//

#import <UIKit/UIKit.h>

@interface BFRImageViewController : UIViewController

- (instancetype _Nullable)init NS_UNAVAILABLE;

/*! Initializes an instance of @C BFRImageViewController from the image source provided. The array can contain a mix of @c NSURL, @c UIImage, @c PHAsset, @c BFRBackLoadedImageSource or @c NSStrings of URLS. This can be a mix of all these types, or just one. */
- (instancetype _Nullable)initWithImageSource:(NSArray * _Nonnull)images;

/*! Initializes an instance of @C BFRImageViewController from the image source provided. The array can contain a mix of @c NSURL, @c UIImage, @c PHAsset, or @c NSStrings of URLS. This can be a mix of all these types, or just one. Additionally, this customizes the user interface to defer showing some of its user interface elements, such as the close button, until it's been fully popped.*/
- (instancetype _Nullable)initForPeekWithImageSource:(NSArray * _Nonnull)images;

/*! Reinitialize with a new images array. Can be used to change the view controller's content on demand */
- (void)setImageSource:(NSArray * _Nonnull)images;

/*! Assigning YES to this property will make the background transparent. Default is NO. */
@property (nonatomic, getter=isUsingTransparentBackground) BOOL useTransparentBackground;

/*! Assigning YES to this property will disable long pressing media to present the activity view controller. Default is NO. */
@property (nonatomic, getter=shouldDisableSharingLongPress) BOOL disableSharingLongPress;

/*! Flag property that toggles the doneButton. Defaults to YES */
@property (nonatomic) BOOL enableDoneButton;

/*! Flag property that sets the doneButton position (left or right side). Defaults to YES */
@property (nonatomic) BOOL showDoneButtonOnLeft;

/*! Allows you to assign an index which to show first when opening multiple images. */
@property (nonatomic, assign) NSInteger startingIndex;

/*! Retrieve the index of the currently showing image. */
@property (nonatomic, assign, readonly) NSInteger currentIndex;

/*! Allows you to enable autoplay for peek&play feature on photo live view. Default to YES */
@property (nonatomic, getter=shouldDisableAutoplayForLivePhoto) BOOL disableAutoplayForLivePhoto;

/*! Dismiss properly with animations */
- (void)dismiss;

/*! Dismiss properly with animations and an optional completion handler */
- (void)dismissWithCompletion:(void (^ __nullable)(void))completion;

/*! Dismiss properly without custom animations */
- (void)dismissWithoutCustomAnimation;

/*! Dismiss properly without custom animations and an optional completion handler  */
- (void)dismissWithoutCustomAnimationWithCompletion:(void (^ __nullable)(void))completion;

@end
