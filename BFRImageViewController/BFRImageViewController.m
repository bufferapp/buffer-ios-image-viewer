//
//  BFRImageViewController.m
//  Buffer
//
//  Created by Jordan Morgan on 11/13/15.
//
//

#import "BFRImageViewController.h"
#import "BFRImageContainerViewController.h"

@interface BFRImageViewController () <UIPageViewControllerDataSource>

/*! This view controller just acts as a container to hold a page view controller, which pages between the view controllers that hold an image. */
@property (strong, nonatomic) UIPageViewController *pagerVC;

/*! Each image displayed is shown in its own instance of a BFRImageViewController. This array holds all of those view controllers, one per image. */
@property (strong, nonatomic) NSMutableArray *imageViewControllers;

/*! Each image is represented via a @c NSURL or an actual @c UIImage. */
@property (strong, nonatomic) NSArray *images;

/*! This will automatically hide the "Done" button after five seconds. */
@property (strong, nonatomic) NSTimer *timerHideUI;

/*! The button that sticks to the top left of the view that is responsible for dismissing this view controller. */
@property (strong, nonatomic) UIButton *doneButton;

/*! This will determine whether to change certain behaviors for 3D touch considerations based on its value. */
@property (nonatomic, getter=isBeingUsedFor3DTouch) BOOL usedFor3DTouch;

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
        self.usedFor3DTouch = YES;
    }
    
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //View setup
    self.view.backgroundColor = self.isUsingTransparentBackground ? [UIColor clearColor] : [UIColor blackColor];
    if (self.shouldHideStatusBar) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    
    //Setup image view controllers
    self.imageViewControllers = [NSMutableArray new];
    for (id imgSrc in self.images) {
        BFRImageContainerViewController *imgVC = [BFRImageContainerViewController new];
        imgVC.imgSrc = imgSrc;
        imgVC.pageIndex += self.startingIndex;
        imgVC.useTransparentBackground = self.isUsingTransparentBackground;
        imgVC.disableHorizontalDrag = (self.images.count > 1);
        [self.imageViewControllers addObject:imgVC];
    }
    
    //Set up pager
    self.pagerVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    if (self.imageViewControllers.count > 1) {
        self.pagerVC.dataSource = self;
    }
    [self.pagerVC setViewControllers:@[self.imageViewControllers[self.startingIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    //Add pager to view hierarchy
    [self addChildViewController:self.pagerVC];
    [[self view] addSubview:[self.pagerVC view]];
    [self.pagerVC didMoveToParentViewController:self];
    
    //Add chrome to UI now if we aren't waiting to be peeked into
    if (!self.isBeingUsedFor3DTouch) {
        [self addChromeToUI];
    }
    
    //Register for touch events on the images/scrollviews to hide UI chrome
    [self registerNotifcations];
}

- (void)addChromeToUI {
    if (self.enableDoneButton) {
        UIImage *crossImage = [UIImage imageNamed:@"cross"];
        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.doneButton setImage:crossImage forState:UIControlStateNormal];
        [self.doneButton addTarget:self action:@selector(handleDoneAction) forControlEvents:UIControlEventTouchUpInside];
        self.doneButton.frame = CGRectMake(20, 20, 17, 17);

        [self.view addSubview:self.doneButton];
        [self.view bringSubviewToFront:self.doneButton];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Pager Datasource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((BFRImageContainerViewController *)viewController).pageIndex;
    
    if (index == 0) {
        return nil;
    }
    
    //Update index
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
    self.pagerVC.dataSource = nil;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handlePop {
    self.view.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self addChromeToUI];
}

- (void)handleDoneAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*! The images and scrollview are not part of this view controller, so instances of @c BFRimageContainerViewController will post notifications when they are touched for things to happen. */
- (void)registerNotifcations {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"DismissUI" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"ImageLoadingError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePop) name:@"ViewControllerPopped" object:nil];
}
@end
