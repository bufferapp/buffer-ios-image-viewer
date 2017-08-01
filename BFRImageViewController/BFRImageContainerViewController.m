//
//  BFRImageContainerViewController.m
//  Buffer
//
//  Created by Jordan Morgan on 11/10/15.
//
//

#import "BFRImageContainerViewController.h"
#import "BFRBackLoadedImageSource.h"
#import <Photos/Photos.h>
#import <DACircularProgress/DACircularProgressView.h>
#import <PINRemoteImage/PINRemoteImage.h>
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>

@interface BFRImageContainerViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

/*! This is responsible for panning and zooming the images. */
@property (strong, nonatomic, nonnull) UIScrollView *scrollView;

/*! The actual view which will display the @c UIImage, this is housed inside of the scrollView property. */
@property (strong, nonatomic, nullable) FLAnimatedImageView *imgView;

/*! The image created from the passed in imgSrc property. */
@property (strong, nonatomic, nullable) UIImage *imgLoaded;

/*! The image created from the passed in animatedImgLoaded property. */
@property (strong, nonatomic, nullable) FLAnimatedImage *animatedImgLoaded;

/*! If the imgSrc property requires a network call, this displays inside the view to denote the loading progress. */
@property (strong, nonatomic, nullable) DACircularProgressView *progressView;

/*! The animator which attaches the behaviors needed to drag the image. */
@property (strong, nonatomic, nonnull) UIDynamicAnimator *animator;

/*! The behavior which allows for the image to "snap" back to the center if it's vertical offset isn't passed the closing points. */
@property (strong, nonatomic, nonnull) UIAttachmentBehavior *imgAttatchment;

@end

@implementation BFRImageContainerViewController

#pragma mark - Lifecycle
// With peeking and popping, setting up your subviews in loadView will throw an exception
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // View setup
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor clearColor];
    
    // Scrollview (for pinching in and out of image)
    self.scrollView = [self createScrollView];
    [self.view addSubview:self.scrollView];
    
    // Fetch image - or just display it
    if ([self.imgSrc isKindOfClass:[NSURL class]]) {
        self.progressView = [self createProgressView];
        [self.view addSubview:self.progressView];
        [self retrieveImageFromURL];
    } else if ([self.imgSrc isKindOfClass:[UIImage class]]) {
        self.imgLoaded = (UIImage *)self.imgSrc;
        [self addImageToScrollView];
    } else if ([self.imgSrc isKindOfClass:[PHAsset class]]) {
        [self retrieveImageFromAsset];
    } else if ([self.imgSrc isKindOfClass:[FLAnimatedImage class]]) {
        self.imgLoaded = ((FLAnimatedImage *)self.imgSrc).posterImage;
        [self retrieveImageFromFLAnimatedImage];
    } else if ([self.imgSrc isKindOfClass:[NSString class]]) {
        // Loading view
        NSURL *url = [NSURL URLWithString:self.imgSrc];
        self.imgSrc = url;
        self.progressView = [self createProgressView];
        [self.view addSubview:self.progressView];
        [self retrieveImageFromURL];
    } else if ([self.imgSrc isKindOfClass:[BFRBackLoadedImageSource class]]) {
        self.imgLoaded = ((BFRBackLoadedImageSource *)self.imgSrc).image;
        [self addImageToScrollView];
        
        __weak BFRImageContainerViewController *weakSelf = self;
        ((BFRBackLoadedImageSource *)self.imgSrc).onHighResImageLoaded = ^ (UIImage *highResImage) {
            weakSelf.imgLoaded = highResImage;
            weakSelf.imgView.image = weakSelf.imgLoaded;
        };
    } else {
        [self showError];
    }
    
    // Animator - used to snap the image back to the center when done dragging
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.scrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePop) name:@"ViewControllerPopped" object:nil];
}

- (void)viewWillLayoutSubviews {
    // Scrollview
    [self.scrollView setFrame:self.view.bounds];
    
    // Set the aspect ratio of the image
    float hfactor = self.imgLoaded.size.width / self.view.bounds.size.width;
    float vfactor = self.imgLoaded.size.height /  self.view.bounds.size.height;
    float factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = self.imgLoaded.size.width / factor;
    float newHeight = self.imgLoaded.size.height / factor;
    
    // Then figure out offset to center vertically or horizontally
    float leftOffset = (self.view.bounds.size.width - newWidth) / 2;
    float topOffset = ( self.view.bounds.size.height - newHeight) / 2;
    
    // Reposition image view
    CGRect newRect = CGRectMake(leftOffset, topOffset, newWidth, newHeight);

    // Check for any NaNs, which should get corrected in the next drawing cycle
    BOOL isInvalidRect = (isnan(leftOffset) || isnan(topOffset) || isnan(newWidth) || isnan(newHeight));
    self.imgView.frame = isInvalidRect ? CGRectZero : newRect;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI Methods
- (UIScrollView *)createScrollView {
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    sv.delegate = self;
    sv.showsHorizontalScrollIndicator = NO;
    sv.showsVerticalScrollIndicator = NO;
    sv.decelerationRate = UIScrollViewDecelerationRateFast;
    sv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //For UI Toggling
    UITapGestureRecognizer *singleSVTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissUI)];
    singleSVTap.numberOfTapsRequired = 1;
    singleSVTap.cancelsTouchesInView = NO;
    [sv addGestureRecognizer:singleSVTap];
    
    return sv;
}

- (DACircularProgressView *)createProgressView {
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    
    DACircularProgressView *progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake((screenWidth-35.)/2., (screenHeight-35.)/2, 35.0f, 35.0f)];
    [progressView setProgress:0.0f];
    progressView.thicknessRatio = 0.1;
    progressView.roundedCorners = NO;
    progressView.trackTintColor = [UIColor colorWithWhite:0.2 alpha:1];
    progressView.progressTintColor = [UIColor colorWithWhite:1.0 alpha:1];
    
    return progressView;
}

- (FLAnimatedImageView *)createImageView {
    FLAnimatedImageView *resizableImageView;
    
    if(self.animatedImgLoaded){
        resizableImageView = [[FLAnimatedImageView alloc] init];
        [resizableImageView setAnimatedImage:self.animatedImgLoaded];
    } else {
        resizableImageView = [[FLAnimatedImageView alloc] initWithImage:self.imgLoaded];
    }
    
    resizableImageView.frame = self.view.bounds;
    resizableImageView.clipsToBounds = YES;
    resizableImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizableImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    resizableImageView.layer.cornerRadius = self.isBeingUsedFor3DTouch ? 14.0f : 0.0f;
    
    // Toggle UI controls
    UITapGestureRecognizer *singleImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissUI)];
    singleImgTap.numberOfTapsRequired = 1;
    [resizableImageView setUserInteractionEnabled:YES];
    [resizableImageView addGestureRecognizer:singleImgTap];
    
    // Reset the image on double tap
    UITapGestureRecognizer *doubleImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recenterImageOriginOrZoomToPoint:)];
    doubleImgTap.numberOfTapsRequired = 2;
    [resizableImageView addGestureRecognizer:doubleImgTap];
    
    // Share options
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showActivitySheet:)];
    [resizableImageView addGestureRecognizer:longPress];
    
    // Ensure the single tap doesn't fire when a user attempts to double tap
    [singleImgTap requireGestureRecognizerToFail:doubleImgTap];
    [singleImgTap requireGestureRecognizerToFail:longPress];
    
    // Dragging to dismiss
    UIPanGestureRecognizer *panImg = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    if (self.shouldDisableHorizontalDrag) {
        panImg.delegate = self;
    }
    [resizableImageView addGestureRecognizer:panImg];
    
    return resizableImageView;
}

- (void)addImageToScrollView {
    if (!self.imgView) {
        self.imgView = [self createImageView];
        [self.scrollView addSubview:self.imgView];
        [self setMaxMinZoomScalesForCurrentBounds];
    }
}

#pragma mark - Gesture Recognizer Delegate
// If we have more than one image, this will cancel out dragging horizontally to make it easy to navigate between images
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.scrollView];
    return fabs(velocity.y) > fabs(velocity.x);
}

#pragma mark - Scrollview Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.scrollView.subviews.firstObject;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self.animator removeAllBehaviors];
    [self centerScrollViewContents];
}

#pragma mark - Scrollview Util Methods
/*! This calculates the correct zoom scale for the scrollview once we have the image's size */
- (void)setMaxMinZoomScalesForCurrentBounds {
    // Sizes
    CGSize boundsSize = self.scrollView.bounds.size;
    CGSize imageSize = self.imgView.frame.size;

    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    
    // Calculate Max
    CGFloat maxScale = 4.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
        
        if (maxScale < minScale) {
            maxScale = minScale * 2;
        }
    }
    
    // Apply zoom
    self.scrollView.maximumZoomScale = maxScale;
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.zoomScale = minScale;
}

/*! Called during zooming of the image to ensure it stays centered */
- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imgView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imgView.frame = contentsFrame;
}

/*! Called when an image is double tapped. Either zooms out or to specific point */
- (void)recenterImageOriginOrZoomToPoint:(UITapGestureRecognizer *)tap {
    if (self.scrollView.zoomScale == self.scrollView.maximumZoomScale) {
        // Zoom out since we zoomed in here
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        //Zoom to a point
        CGPoint touchPoint = [tap locationInView:self.scrollView];
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
}


#pragma mark - Dragging and Long Press Methods
/*! This method has three different states due to the gesture recognizer. In them, we either add the required behaviors using UIDynamics, update the image's position based off of the touch points of the drag, or if it's ended we snap it back to the center or dismiss this view controller if the vertical offset meets the requirements. */
- (void)handleDrag:(UIPanGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.animator removeAllBehaviors];
        
        CGPoint location = [recognizer locationInView:self.scrollView];
        CGPoint imgLocation = [recognizer locationInView:self.imgView];
        
        UIOffset centerOffset = UIOffsetMake(imgLocation.x - CGRectGetMidX(self.imgView.bounds),
                                             imgLocation.y - CGRectGetMidY(self.imgView.bounds));
        
        self.imgAttatchment = [[UIAttachmentBehavior alloc] initWithItem:self.imgView offsetFromCenter:centerOffset attachedToAnchor:location];
        [self.animator addBehavior:self.imgAttatchment];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self.imgAttatchment setAnchorPoint:[recognizer locationInView:self.scrollView]];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [recognizer locationInView:self.scrollView];
        CGRect closeTopThreshhold = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * .35);
        CGRect closeBottomThreshhold = CGRectMake(0, self.view.bounds.size.height - closeTopThreshhold.size.height, self.view.bounds.size.width, self.view.bounds.size.height * .35);
        
        // Check if we should close - or just snap back to the center
        if (CGRectContainsPoint(closeTopThreshhold, location) || CGRectContainsPoint(closeBottomThreshhold, location)) {
            [self.animator removeAllBehaviors];
            self.imgView.userInteractionEnabled = NO;
            self.scrollView.userInteractionEnabled = NO;
            
            UIGravityBehavior *exitGravity = [[UIGravityBehavior alloc] initWithItems:@[self.imgView]];
            if (CGRectContainsPoint(closeTopThreshhold, location)) {
                exitGravity.gravityDirection = CGVectorMake(0.0, -1.0);
            }
            exitGravity.magnitude = 15.0f;
            [self.animator addBehavior:exitGravity];
            
            [UIView animateWithDuration:0.25f animations:^ {
                self.imgView.alpha = 0.25f;
            } completion:^ (BOOL done) {
                self.imgView.alpha = 0.0f;
                [self dimissUIFromDraggingGesture];
            }];
            
        } else {
            [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
            UISnapBehavior *snapBack = [[UISnapBehavior alloc] initWithItem:self.imgView snapToPoint:self.scrollView.center];
            [self.animator addBehavior:snapBack];
        }
    }
}

- (void)showActivitySheet:(UILongPressGestureRecognizer *)longPress {
    
    UIActivityViewController *activityVC;
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.imgLoaded] applicationActivities:nil];
            [self presentViewController:activityVC animated:YES completion:nil];
        } else {
            activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.imgLoaded] applicationActivities:nil];
            activityVC.modalPresentationStyle = UIModalPresentationPopover;
            activityVC.preferredContentSize = CGSizeMake(320,400);
            UIPopoverPresentationController *popoverVC = activityVC.popoverPresentationController;
            popoverVC.sourceView = self.imgView;
            CGPoint touchPoint = [longPress locationInView:self.imgView];
            popoverVC.sourceRect = CGRectMake(touchPoint.x, touchPoint.y, 1, 1);
            [self presentViewController:activityVC animated:YES completion:nil];
        }
    }
}

#pragma mark - Image Asset Retrieval
- (void)retrieveImageFromAsset {
    if (![self.imgSrc isKindOfClass:[PHAsset class]]) {
        return;
    }
    
    PHImageRequestOptions *reqOptions = [PHImageRequestOptions new];
    reqOptions.synchronous = YES;
    [[PHImageManager defaultManager] requestImageDataForAsset:self.imgSrc options:reqOptions resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        self.imgLoaded = [UIImage imageWithData:imageData];
        [self addImageToScrollView];
    }];
}

- (void)retrieveImageFromFLAnimatedImage {
    if (![self.imgSrc isKindOfClass:[FLAnimatedImage class]]) {
        return;
    }
    
    FLAnimatedImage *image = (FLAnimatedImage *)self.imgSrc;
    self.imgLoaded = image.posterImage;
    self.animatedImgLoaded = image;
    
    [self addImageToScrollView];
}

- (void)retrieveImageFromURL {
    NSURL *url = (NSURL *)self.imgSrc;
    
    [[PINRemoteImageManager sharedImageManager] downloadImageWithURL:url options:0 progressDownload:^(int64_t completedBytes, int64_t totalBytes) {
        float fractionCompleted = (float)completedBytes/(float)totalBytes;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView setProgress:fractionCompleted];
        });
    } completion:^(PINRemoteImageManagerResult * _Nonnull result) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!result.image && !result.alternativeRepresentation) {
                [self.progressView removeFromSuperview];
                [self showError];
                return;
            }
            
            if(result.alternativeRepresentation){
                self.imgSrc = result.alternativeRepresentation;
                [self retrieveImageFromFLAnimatedImage];
            } else {
                self.imgLoaded = result.image;
            }
            
            [self addImageToScrollView];
            [self.progressView removeFromSuperview];
        });
    }];
}

#pragma mark - Misc. Methods
- (void)dismissUI {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissUI" object:nil];
}

- (void)dimissUIFromDraggingGesture {
    // If we drag the image away to close things, don't do the custom dismissal transition
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DimissUIFromDraggingGesture" object:nil];
}

- (void)showError {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Whoops" message:@"Looks like we ran into an issue loading the image, sorry about that!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageLoadingError" object:nil];
    }];
    [controller addAction:closeAction];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)handlePop {
    self.imgView.layer.cornerRadius = 0.0f;
}

@end
