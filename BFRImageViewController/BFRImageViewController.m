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
/*! The button that sticks to the top right of the view that is responsible for dismissing this view controller. */
@property (strong, nonatomic) UIButton *doneButton;
@end

@implementation BFRImageViewController

#pragma mark - Initializers
- (instancetype)initWithImageSource:(NSArray *)images {
    self = [super init];
    
    if (self) {
        NSAssert(images.count > 0, @"You must supply at least one image source to use this class.");
        self.images = images;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
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
        imgVC.useTransparentBackground = self.isUsingTransparentBackground;
        [self.imageViewControllers addObject:imgVC];
    }
    
    //Set up pager
    self.pagerVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    if (self.imageViewControllers.count > 1) {
        self.pagerVC.dataSource = self;
    }
    [self.pagerVC setViewControllers:@[self.imageViewControllers.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    //Add pager to view hierarchy
    [self addChildViewController:self.pagerVC];
    [[self view] addSubview:[self.pagerVC view]];
    [self.pagerVC didMoveToParentViewController:self];
    
    //Register for touch events on the images/scrollviews to hide UI chrome
    [self registerNotifcations];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI Methods
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //Buttons
    [self.doneButton setFrame:CGRectMake(self.view.bounds.size.width - 75, 30, 55, 26)];
    [self.view bringSubviewToFront:self.doneButton];
}

- (UIButton *)createDoneButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect screenBound = self.view.bounds;
    CGFloat screenWidth = screenBound.size.width;
    [btn setFrame:CGRectMake(screenWidth - 75, 30, 55, 26)];
    [btn setTitleColor:[UIColor colorWithWhite:0.9 alpha:0.9] forState:UIControlStateNormal|UIControlStateHighlighted];
    [btn setTitle:@"Done" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
    [btn setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.5]];
    btn.layer.cornerRadius = 3.0f;
    btn.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.9].CGColor;
    btn.layer.borderWidth = 1.0f;
    
    return btn;
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
}

/*! The images and scrollview are not part of this view controller, so instances of @c BFRimageContainerViewController will post notifications when they are touched for things to happen. */
- (void)registerNotifcations {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"DismissUI" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"ImageLoadingError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePop) name:@"ViewControllerPopped" object:nil];
}
@end
