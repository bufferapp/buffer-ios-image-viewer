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
@property (strong, nonatomic) id imgSrc;

/*! A helper integer to simplify using this view controller inside a @c UIPagerViewController when swiping between views. */
@property (nonatomic, assign) NSUInteger pageIndex;

/*! Assigning YES to this property will make the background transparent. */
@property (nonatomic, getter=isUsingTransparentBackground) BOOL useTransparentBackground;

/*! If there is more than one image in the containing @c BFRImageViewController - this property is set to YES to make swiping from image to image easier. */
@property (nonatomic, getter=shouldDisableHorizontalDrag) BOOL disableHorizontalDrag;

@end
