//
//  BufferImageViewController.swift
//  BFRImageViewer
//
//  Created by Jordan Morgan on 11/13/15.
//
//

import UIKit

public class BufferImageViewController: UIViewController {
    
    /// Assigning **true** to this property will make the background transparent.
    public var  useTransparentBackground = false
    
    /// When peeking, iOS already hides the status bar for you. In that case, leave this to the default value of NO. If you are using this class outside of 3D touch, set this to **true**.
    public var hideStatusBar = false
    
    /// Flag property that toggles the doneButton. Defaults to **true**
    public var enableDoneButton = true
    
    /// Flag property that sets the doneButton position (left or right side). Defaults to **true**
    public var showDoneButtonOnLeft = true
    
    /// This view controller just acts as a container to hold a page view controller, which pages between the view controllers that hold an image.
    let pagerVC: UIPageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options:nil)
    
    /// Each image displayed is shown in its own instance of a BFRImageViewController. This array holds all of those view controllers, one per image.
    var imageViewControllers: [BufferImageContainerViewController] = [BufferImageContainerViewController]()
    
    /// Each image is represented via a @c NSURL or an actual @c UIImage.
    var images: [AnyObject] = [AnyObject]()
    
    /// This will automatically hide the "Done" button after five seconds.
    var timerHideUI: NSTimer?
    // TODO Implement timer
    
    /// The button that sticks to the top left of the view that is responsible for dismissing this view controller.
    var doneButton: UIButton?
    
    /// This will determine whether to change certain behaviors for 3D touch considerations based on its value.
    var usedFor3DTouch: Bool = false
    
    var imageRetriever: BufferImageRetriever!
    
    // MARK: - Initializers
    
    /**
     Initializes an instance of BFRImageViewController from the image source provided. The array can contain a mix of NSURL, UIImage, PHAsset, or NSStrings of URLS. This can be a mix of all these types, or just one.
     
     - parameter imageSource: Images represented by one or more:
     - NSURL
     - UIImage
     - PHAsset
     - Strings of URLs
     - parameter imageRetriever: Will retrieve images from remote URLs
     
     - returns: A newly initialized BufferImageViewController object.
     */
    public init(imageSource images: [AnyObject], imageRetriever: BufferImageRetriever) {
        super.init(nibName: nil, bundle: nil)
        
        precondition(images.count > 0, "You must supply at least one image source to use this class.")
        
        self.images               = images
        self.modalTransitionStyle = .CrossDissolve
        self.enableDoneButton     = true
        self.showDoneButtonOnLeft = true
        self.imageRetriever       = imageRetriever
    }
    
    /**
     Initializes an instance of BFRImageViewController from the image source provided. The array can contain a mix of NSURL, UIImage, PHAsset, or NSStrings of URLS. This can be a mix of all these types, or just one.
     Additionally, this customizes the user interface to defer showing some of its user interface elements, such as the close button, until it's been fully popped.
     
     - parameter forPeekWithImageSource: Images represented by one or more:
        - NSURL
        - UIImage
        - PHAsset
        - Strings of URLs
     - parameter imageRetriever: Will retrieve images from remote URLs
     
     - returns: A newly initialized BufferImageViewController object.
     */
    public init(forPeekWithImageSource images: [AnyObject], imageRetriever: BufferImageRetriever) {
        super.init(nibName: nil, bundle: nil)
        
        precondition(images.count > 0, "You must supply at least one image source to use this class.")
        
        self.images               = images
        self.modalTransitionStyle = .CrossDissolve
        self.enableDoneButton     = true
        self.showDoneButtonOnLeft = true
        self.usedFor3DTouch       = true
        self.imageRetriever       = imageRetriever
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        //View setup
        self.view.backgroundColor = self.useTransparentBackground ? UIColor.clearColor() : UIColor(white: 0, alpha: 1)
        
        //Setup image view controllers
        for imgSrc in self.images {
            let imgVC    = BufferImageContainerViewController()
            imgVC.imgSrc = imgSrc
            imgVC.useTransparentBackground = self.useTransparentBackground
            imgVC.disableHorizontalDrag    = !self.images.isEmpty
            imgVC.imageRetriever           = imageRetriever
            self.imageViewControllers.append(imgVC)
        }
        
        //Set up pager
        if let firstVc = self.imageViewControllers.first {
            self.pagerVC.dataSource = self
            self.pagerVC.setViewControllers([firstVc], direction:.Forward, animated: false, completion: nil)
        }
        
        //Add pager to view hierarchy
        self.addChildViewController(self.pagerVC)
        self.view.addSubview(self.pagerVC.view)
        self.pagerVC.didMoveToParentViewController(self)
        
        //Add chrome to UI now if we aren't waiting to be peeked into
        if !self.usedFor3DTouch {
            self.addChromeToUI()
        }
        
        //Register for touch events on the images/scrollviews to hide UI chrome
        self.registerNotifcations()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.updateChromeFrames()
    }
    
    deinit {
        // Not needed anymore ?
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return self.hideStatusBar
    }
    
    
    // MARK: - Chrome
    
    func addChromeToUI() {
        guard self.enableDoneButton else { return }
        
        let bundle = NSBundle(forClass: BufferImageViewController.self)
        guard let imagePath = bundle.pathForResource("cross", ofType:"png") else { return }
        
        let crossImage = UIImage(contentsOfFile: imagePath)
        
        self.doneButton = UIButton(type: .Custom)
        self.doneButton!.setImage(crossImage, forState: .Normal)
        self.doneButton!.addTarget(self, action: #selector(handleDoneAction), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.doneButton!)
        self.view.bringSubviewToFront(self.doneButton!)
        
        self.updateChromeFrames()
    }
    
    func updateChromeFrames() {
        guard self.enableDoneButton else { return }
        
        let buttonX = self.showDoneButtonOnLeft ? 20 : CGRectGetMaxX(self.view.bounds) - 37
        self.doneButton?.frame = CGRectMake(buttonX, 20, 17, 17)
    }
    
    // MARK: - Utility methods
    
    func dismiss() {
        self.pagerVC.dataSource = nil
        self.modalTransitionStyle = .CrossDissolve
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func handlePop() {
        self.view.backgroundColor = .blackColor()
        self.addChromeToUI()
    }
    
    func handleDoneAction() {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    /// The images and scrollview are not part of this view controller, so instances of @c BFRimageContainerViewController will post notifications when they are touched for things to happen.
    func registerNotifcations() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter
            .addObserver(self, selector:#selector(dismiss), name:"DismissUI", object:nil)
        notificationCenter
            .addObserver(self, selector:#selector(dismiss), name:"ImageLoadingError", object:nil)
        notificationCenter
            .addObserver(self, selector:#selector(handlePop), name:"ViewControllerPopped", object:nil)
        notificationCenter
            .addObserver(self, selector:#selector(imageSnappedBack), name:"ImageSnappedBack", object:nil)
        notificationCenter
            .addObserver(self, selector:#selector(imageDragged(_:)), name:"ImageDragged", object:nil)
    }
    
    func imageDragged(notification: NSNotification) {
        guard let offset = notification.object as? CGFloat else {
            return
        }
        
        self.view.alpha = 1-offset
//        self.view.backgroundColor = UIColor(white: offset, alpha: 1-offset)
    }
    
    func imageSnappedBack() {
        let minusAlpha: Double = 1 - Double(view.alpha)
        UIView.animateWithDuration(minusAlpha) {
            self.view.backgroundColor = UIColor(white: 0, alpha: 1)
            self.view.alpha = 1.0
        }
    }
    
}

extension BufferImageViewController: UIPageViewControllerDataSource {
    
    // MARK: - Pager Datasource
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        guard let viewController = viewController as? BufferImageContainerViewController
            where viewController.pageIndex != 0 else {
                return nil
        }
        
        //Update index
        let index = viewController.pageIndex - 1
        let vc = self.imageViewControllers[index]
        vc.pageIndex = index
        
        return vc
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        guard let viewController = viewController as? BufferImageContainerViewController
            where viewController.pageIndex != self.imageViewControllers.count - 1 else {
                return nil
        }
        
        //Update index
        let index = viewController.pageIndex + 1
        let vc = self.imageViewControllers[index]
        vc.pageIndex = index
        
        return vc
    }
    
}
