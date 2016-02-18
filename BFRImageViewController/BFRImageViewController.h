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

/*! Assigning YES to this property will make the background transparent. */
@property (nonatomic, getter=isUsingTransparentBackground) BOOL useTransparentBackground;

/*! When peeking, iOS already hides the status bar for you. In that case, leave this to the default value of NO. If you are using this class outside of 3D touch, set this to YES. */
@property (nonatomic, getter=shouldHideStatusBar) BOOL hideStatusBar;

@end
