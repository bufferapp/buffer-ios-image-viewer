//
//  BFRImageViewController.h
//  Buffer
//
//  Created by Jordan Morgan on 11/13/15.
//
//

#import <UIKit/UIKit.h>

@interface BFRImageViewController : UIViewController

/*! Initializes an instance of @C BFRImageViewController from the image source provided. The array can contain a mix of @c NSURL, @c UIImage, @c PHAsset, or @c NSStrings of URLS. This can be a mix of all these types, or just one. */
- (instancetype)initWithImageSource:(NSArray *)images;

/*! Initializes an instance of @C BFRImageViewController from the image source provided. The array can contain a mix of @c NSURL, @c UIImage, @c PHAsset, or @c NSStrings of URLS. This can be a mix of all these types, or just one. Additionally, this customizes the user interface to defer showing some of its user interface elements, such as the close button, until it's been fully popped.*/
- (instancetype)initForPeekWithImageSource:(NSArray *)images;

/*! Assigning YES to this property will make the background transparent. */
@property (nonatomic, getter=isUsingTransparentBackground) BOOL useTransparentBackground;

/*! Assigning YES to this property will make ensure the first image doesn't load for 0.15f, so the custom view controller animation can finish putting the image in its final frame. */
@property (nonatomic, getter=customTransitionIsEnabled) BOOL customTransitionEnabled;

/*! Flag property that toggles the doneButton. Defaults to YES */
@property (nonatomic) BOOL enableDoneButton;

/*! Flag property that sets the doneButton position (left or right side). Defaults to YES */
@property (nonatomic) BOOL showDoneButtonOnLeft;

/*! Allows you to assign an index which to show first when opening multiple images. */
@property (nonatomic, assign) NSInteger startingIndex;

@end
