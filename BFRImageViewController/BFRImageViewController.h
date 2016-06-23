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

/*! When peeking, iOS already hides the status bar for you. In that case, leave this to the default value of NO. If you are using this class outside of 3D touch, set this to YES. */
@property (nonatomic, getter=shouldHideStatusBar) BOOL hideStatusBar;

/*! Flag property that lets disable the doneButton. Default to YES */
@property (nonatomic) BOOL enableDoneButton;

@property (nonatomic, assign) NSInteger startingIndex;

@end
