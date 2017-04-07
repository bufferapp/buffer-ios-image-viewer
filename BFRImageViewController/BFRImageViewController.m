//
//  BFRImageViewController.m
//  Buffer
//
//  Created by Jordan Morgan on 11/13/15.
//
//

#import "BFRImageViewController.h"
#import "BFRImageContainerViewController.h"
#import "BFRImageViewerLocalizations.h"
#import "BFRImageTransitionAnimator.h"

@interface BFRImageViewController () <UIPageViewControllerDataSource>

/*! This view controller just acts as a container to hold a page view controller, which pages between the view controllers that hold an image. */
@property (strong, nonatomic, nonnull) UIPageViewController *pagerVC;

/*! Each image displayed is shown in its own instance of a BFRImageViewController. This array holds all of those view controllers, one per image. */
@property (strong, nonatomic, nonnull) NSMutableArray <BFRImageContainerViewController *> *imageViewControllers;

/*! This can contain a mix of @c NSURL, @c UIImage, @c PHAsset, @c BFRBackLoadedImageSource or @c NSStrings of URLS. This can be a mix of all these types, or just one. */
@property (strong, nonatomic, nonnull) NSArray *images;

/*! This will automatically hide the "Done" button after five seconds. */
@property (strong, nonatomic, nullable) NSTimer *timerHideUI;

/*! The button that sticks to the top left of the view that is responsible for dismissing this view controller. */
@property (strong, nonatomic, nullable) UIButton *doneButton;

/*! This will determine whether to change certain behaviors for 3D touch considerations based on its value. */
@property (nonatomic, getter=isBeingUsedFor3DTouch) BOOL usedFor3DTouch;

/*! This is used for nothing more than to defer the hiding of the status bar until the view appears to avoid any awkward jumps in the presenting view. */
@property (nonatomic, getter=shouldHideStatusBar) BOOL hideStatusBar;

@end

@implementation BFRImageViewController

#pragma mark - Initializers
- (instancetype)initWithImageSource:(NSArray *)images {
    self = [super init];
    
    if (self) {
        NSAssert(images.count > 0, @"You must supply at least one image source to use this class.");
        self.images = images;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.enableDoneButton = YES;
        self.showDoneButtonOnLeft = YES;
    }
    
    return self;
}

- (instancetype)initForPeekWithImageSource:(NSArray *)images {
    self = [super init];
    
    if (self) {
        NSAssert(images.count > 0, @"You must supply at least one image source to use this class.");
        self.images = images;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.enableDoneButton = YES;
        self.showDoneButtonOnLeft = YES;
        self.usedFor3DTouch = YES;
    }
    
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // View setup
    self.view.backgroundColor = self.isUsingTransparentBackground ? [UIColor clearColor] : [UIColor blackColor];

    // Ensure starting index won't trap
    if (self.startingIndex >= self.images.count || self.startingIndex < 0) {
        self.startingIndex = 0;
    }
    
    // Setup image view controllers
    self.imageViewControllers = [NSMutableArray new];
    for (id imgSrc in self.images) {
        BFRImageContainerViewController *imgVC = [BFRImageContainerViewController new];
        imgVC.imgSrc = imgSrc;
        imgVC.pageIndex = self.startingIndex;
        imgVC.usedFor3DTouch = self.isBeingUsedFor3DTouch;
        imgVC.useTransparentBackground = self.isUsingTransparentBackground;
        imgVC.disableHorizontalDrag = (self.images.count > 1);
        [self.imageViewControllers addObject:imgVC];
    }
    
    // Set up pager
    self.pagerVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    if (self.imageViewControllers.count > 1) {
        self.pagerVC.dataSource = self;
    }
    [self.pagerVC setViewControllers:@[self.imageViewControllers[self.startingIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Add pager to view hierarchy
    [self addChildViewController:self.pagerVC];
    [[self view] addSubview:[self.pagerVC view]];
    [self.pagerVC didMoveToParentViewController:self];
    
    // Add chrome to UI now if we aren't waiting to be peeked into
    if (!self.isBeingUsedFor3DTouch) {
        [self addChromeToUI];
    }
    
    // Register for touch events on the images/scrollviews to hide UI chrome
    [self registerNotifcations];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hideStatusBar = YES;
    [UIView animateWithDuration:0.1 animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateChromeFrames];
}

#pragma mark - Status bar
- (BOOL)prefersStatusBarHidden{
    return self.shouldHideStatusBar;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

#pragma mark - Chrome
- (void)addChromeToUI {
    if (self.enableDoneButton) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *imagePath = [bundle pathForResource:@"cross" ofType:@"png"];
        UIImage *crossImage = [[UIImage alloc] initWithContentsOfFile:imagePath];

        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.doneButton setAccessibilityLabel:BFRImageViewerLocalizedStrings(@"imageViewController.closeButton.text", @"Close")];
        [self.doneButton setImage:crossImage forState:UIControlStateNormal];
        [self.doneButton addTarget:self action:@selector(handleDoneAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:self.doneButton];
        [self.view bringSubviewToFront:self.doneButton];
        
        [self updateChromeFrames];
    }
}

- (void)updateChromeFrames {
    if (self.enableDoneButton) {
        CGFloat buttonX = self.showDoneButtonOnLeft ? 20 : CGRectGetMaxX(self.view.bounds) - 37;
        self.doneButton.frame = CGRectMake(buttonX, 20, 17, 17);
    }
}

#pragma mark - Pager Datasource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((BFRImageContainerViewController *)viewController).pageIndex;
    
    if (index == 0) {
        return nil;
    }
    
    // Update index
    index--;
    BFRImageContainerViewController *vc = self.imageViewControllers[index];
    vc.pageIndex = index;
    
    return vc;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((BFRImageContainerViewController *)viewController).pageIndex;
    
    if (index == self.imageViewControllers.count - 1) {
        return nil;
    }
    
    //Update index
    index++;
    BFRImageContainerViewController *vc = self.imageViewControllers[index];
    vc.pageIndex = index;
    
    return vc;
}

#pragma mark - Utility methods
- (void)dismiss {
    // If we dismiss from a different image than what was animated in - don't do the custom dismiss transition animation
    if (self.startingIndex != ((BFRImageContainerViewController *)self.pagerVC.viewControllers.firstObject).pageIndex) {
        [self dismissWithoutCustomAnimation];
        return;
    }
    
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissWithoutCustomAnimation {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CancelCustomDismissalTransition" object:@(1)];

    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handlePop {
    self.view.backgroundColor = [UIColor blackColor];
    [self addChromeToUI];
}

- (void)handleDoneAction {
    [self dismiss];
}

/*! The images and scrollview are not part of this view controller, so instances of @c BFRimageContainerViewController will post notifications when they are touched for things to happen. */
- (void)registerNotifcations {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"DismissUI" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"ImageLoadingError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePop) name:@"ViewControllerPopped" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissWithoutCustomAnimation) name:@"DimissUIFromDraggingGesture" object:nil];
}

#pragma mark - Memory Considerations
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"BFRImageViewer: Dismissing due to memory warning.");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
