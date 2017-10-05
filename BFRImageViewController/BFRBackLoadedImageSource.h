//
//  BFRBackLoadedImageSource.h
//  BFRImageViewer
//
//  Created by Jordan Morgan on 4/6/17.
//  Copyright © 2017 Andrew Yates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^onHiResDownloadComplete)(UIImage * _Nullable,  NSError * _Nullable);

/*! This class allows you to show an image that you already have available initially, while loading a higher fidelity version in the background which will replace the lower fidelity one. This class assumes that the new image will have the same aspect ratio as the old one. */
@interface BFRBackLoadedImageSource : NSObject

/*! The image that is available for use right away. */
@property (strong, nonatomic, readonly, nonnull) UIImage *image;

/*! This is called on the main thread when the higher resolution image is finished loading. Assign to this if you wish to do any specific logic when the download completes. NOTE: Do not attempt to assign the image to any @c BFRImageContainerViewController, this is done for you. Use this block soley for any other business logic you might have to carry out. */
@property (copy) onHiResDownloadComplete _Nullable onCompletion;

/*! Use initWithInitialImage:hiResURL instead. */
- (instancetype _Nullable)init NS_UNAVAILABLE;

/*! Returns an instance of this class that will show the @c UIImage provided first, and then replace it with the high fidelty version when it loads via the passed in @c NSURL. */
- (instancetype _Nullable)initWithInitialImage:(UIImage * _Nonnull)image hiResURL:(NSURL * _Nonnull)url NS_DESIGNATED_INITIALIZER;

@end
