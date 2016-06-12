//
//  BufferImageContainerViewController.swift
//  Buffer
//
//  Created by Jordan Morgan on 11/10/15.
//
//

import UIKit
import Photos
import DACircularProgress

/*! This class holds an image to view, if you need an image viewer alloc @C BFRImageViewController instead. This class isn't meant to instanitated outside of it. */
internal class BufferImageContainerViewController: UIViewController {
    
    /*! Source of the image, which should either be @c NSURL or @c UIImage. */
    var imgSrc: AnyObject!
    
    /*! Cache manager to retrieve images. */
    var imageRetriever: BufferImageRetriever!
    
    /*! A helper integer to simplify using this view controller inside a @c UIPagerViewController when swiping between views. */
    var pageIndex: Int = 0
    
    /*! Assigning **true** to this property will make the background transparent. */
    var useTransparentBackground: Bool = false
    
    /*! If there is more than one image in the containing @c BFRImageViewController - this property is set to **true** to make swiping from image to image easier. */
    var disableHorizontalDrag: Bool = true
    
    /*! This is responsible for panning and zooming the images. */
    private var scrollView: UIScrollView!
    
    /*! The actual view which will display the @c UIImage, this is housed inside of the scrollView property. */
    private var imgView: UIImageView?
    
    /*! The image created from the passed in imgSrc property. */
    private var imgLoaded: UIImage?
    
    /*! If the imgSrc property requires a network call, this displays inside the view to denote the loading progress. */
    private var progressView: DACircularProgressView?
    
    /*! The animator which attaches the behaviors needed to drag the image. */
    private var animator: UIDynamicAnimator!
    
    /*! The behavior which allows for the image to "snap" back to the center if it's vertical offset isn't passed the closing points. */
    private var imgAttatchment: UIAttachmentBehavior?
    
    
    // MARK: - Lifecycle
    
    //With peeking and popping, setting up your subviews in loadView will throw an exception
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //View setup
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = .clearColor()
        
        //Scrollview (for pinching in and out of image)
        self.scrollView = self.createScrollView()
        self.view.addSubview(self.scrollView)
        
        //Fetch image - or just display it
        if let _ = imgSrc as? NSURL {
            self.progressView = self.createProgressView()
            self.view.addSubview(self.progressView!)
            self.retrieveImageFromURL()
        } else if let imgSrc = imgSrc as? UIImage {
            self.imgLoaded = imgSrc
            self.addImageToScrollView()
        } else if let _ = imgSrc as? PHAsset {
            self.retrieveImageFromAsset()
        } else if let imgSrc = imgSrc as? String {
            //Loading view
            let url = NSURL(string: imgSrc)
            self.imgSrc = url
            self.progressView = self.createProgressView()
            self.view.addSubview(self.progressView!)
            self.retrieveImageFromURL()
        }
        
        //Animator - used to snap the image back to the center when done dragging
        self.animator = UIDynamicAnimator(referenceView: self.scrollView)
    }
    
    override func viewWillLayoutSubviews() {
        guard let imgLoaded = imgLoaded,
            let _ = imgView else { return }
        
        //Scrollview
        self.scrollView.frame = self.view.bounds
        
        //Set the aspect ratio of the image
        let hfactor = imgLoaded.size.width  / self.view.bounds.size.width
        let vfactor = imgLoaded.size.height /  self.view.bounds.size.height
        let factor  = fmax(hfactor, vfactor)
        
        //Divide the size by the greater of the vertical or horizontal shrinkage factor
        let newWidth  = imgLoaded.size.width  / factor
        let newHeight = imgLoaded.size.height / factor
        
        //Then figure out offset to center vertically or horizontally
        let leftOffset = (self.view.bounds.size.width   - newWidth)  / 2
        let topOffset  = ( self.view.bounds.size.height - newHeight) / 2
        
        //Reposition image view
        let newRect = CGRectMake(leftOffset, topOffset, newWidth, newHeight)
        
        //Check for any NaNs, which should get corrected in the next drawing cycle
        let isInvalidRect = (isnan(leftOffset) || isnan(topOffset) || isnan(newWidth) || isnan(newHeight))
        self.imgView!.frame = isInvalidRect ? CGRectZero : newRect
    }
    
    // MARK: - UI Methods
    
    func createScrollView() -> UIScrollView {
        let sv = UIScrollView(frame: self.view.bounds)
        sv.delegate = self
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator   = false
        sv.decelerationRate = UIScrollViewDecelerationRateFast
        sv.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        //For UI Toggling
        let singleSVTap = UITapGestureRecognizer(target:self, action:#selector(dismissUI))
        singleSVTap.numberOfTapsRequired = 1
        singleSVTap.cancelsTouchesInView = false
        sv.addGestureRecognizer(singleSVTap)
        
        return sv
    }
    
    func createProgressView() -> DACircularProgressView {
        let screenWidth  = self.view.bounds.size.width
        let screenHeight = self.view.bounds.size.height
        
        let progressView = DACircularProgressView(frame: CGRectMake((screenWidth-35.0)/2.0, (screenHeight-35.0)/2, 35.0, 35.0))
        progressView.progress = 0.0
        progressView.thicknessRatio = 0.1
        progressView.roundedCorners = 0
        progressView.trackTintColor    = UIColor(white:0.2, alpha:1)
        progressView.progressTintColor = UIColor(white:1.0, alpha:1)
        
        return progressView
    }
    
    func createImageView() -> UIImageView {
        let resizableImageView = UIImageView(image: self.imgLoaded)
        resizableImageView.frame           = self.view.bounds;
        resizableImageView.clipsToBounds   = true
        resizableImageView.contentMode     = .ScaleAspectFill
        resizableImageView.backgroundColor = UIColor(white:0, alpha:1)
        
        //Toggle UI controls
        let singleImgTap = UITapGestureRecognizer(target:self, action:#selector(dismissUI))
        singleImgTap.numberOfTapsRequired = 1
        resizableImageView.userInteractionEnabled = true
        resizableImageView.addGestureRecognizer(singleImgTap)
        
        //Reset the image on double tap
        let doubleImgTap = UITapGestureRecognizer(target:self, action:#selector(recenterImageOriginOrZoomToPoint(_:)))
        doubleImgTap.numberOfTapsRequired = 2
        resizableImageView.addGestureRecognizer(doubleImgTap)
        
        //Share options
        let longPress = UILongPressGestureRecognizer(target:self, action:#selector(showActivitySheet(_:)))
        resizableImageView.addGestureRecognizer(longPress)
        
        //Ensure the single tap doesn't fire when a user attempts to double tap
        singleImgTap.requireGestureRecognizerToFail(doubleImgTap)
        singleImgTap.requireGestureRecognizerToFail(longPress)
        
        //Dragging to dismiss
        let panImg = UIPanGestureRecognizer(target:self, action:#selector(handleDrag(_:)))
        if self.disableHorizontalDrag {
            panImg.delegate = self
        }
        resizableImageView.addGestureRecognizer(panImg)
        
        return resizableImageView
    }
    
    func addImageToScrollView() {
        if case .None = self.imgView {
            self.imgView = self.createImageView()
            self.scrollView.addSubview(self.imgView!)
            self.setMaxMinZoomScalesForCurrentBounds()
        }
    }
    
    // MARK: - Dragging and Long Press Methods
    
    /*! This method has three different states due to the gesture recognizer. In them, we either add the required behaviors using UIDynamics, update the image's position based off of the touch points of the drag, or if it's ended we snap it back to the center or dismiss this view controller if the vertical offset meets the requirements. */
    @objc func handleDrag(recognizer: UIPanGestureRecognizer) {
        guard let imgView = imgView else { return }
        
        if recognizer.state == .Began {
            self.animator.removeAllBehaviors()
            
            let location    = recognizer.locationInView(scrollView)
            let imgLocation = recognizer.locationInView(imgView)
            
            let centerOffset = UIOffsetMake(imgLocation.x - CGRectGetMidX(imgView.bounds),
                                            imgLocation.y - CGRectGetMidY(imgView.bounds))
            
            self.imgAttatchment = UIAttachmentBehavior(item:imgView, offsetFromCenter:centerOffset, attachedToAnchor:location)
            self.animator.addBehavior(self.imgAttatchment!)
        } else if recognizer.state == .Changed {
            self.imgAttatchment?.anchorPoint = recognizer.locationInView(self.scrollView)
        } else if recognizer.state == .Ended {
            let location = recognizer.locationInView(self.scrollView)
            let closeTopThreshhold = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * 0.35)
            let closeBottomThreshhold = CGRectMake(0, self.view.bounds.size.height - closeTopThreshhold.size.height, self.view.bounds.size.width, self.view.bounds.size.height * 0.35)
            
            //Check if we should close - or just snap back to the center
            if CGRectContainsPoint(closeTopThreshhold, location) || CGRectContainsPoint(closeBottomThreshhold, location) {
                self.animator.removeAllBehaviors()
                self.imgView!.userInteractionEnabled   = false
                self.scrollView.userInteractionEnabled = false
                
                let exitGravity = UIGravityBehavior(items:[imgView])
                if CGRectContainsPoint(closeTopThreshhold, location) {
                    exitGravity.gravityDirection = CGVectorMake(0.0, -1.0)
                }
                exitGravity.magnitude = 15.0
                self.animator.addBehavior(exitGravity)
                
                let delta = Int64(0.35 * Double(NSEC_PER_SEC))
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), {
                    self.dismissUI()
                })
            } else {
                self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated:true)
                let snapBack = UISnapBehavior(item:imgView, snapToPoint:self.scrollView.center)
                self.animator.addBehavior(snapBack)
            }
        }
    }
    
    @objc func showActivitySheet(longPress: UILongPressGestureRecognizer) {
        guard longPress.state == .Began else { return }
        guard let imgLoaded = imgLoaded,
            let imgView = imgView else { return }
        
        let activityVC = UIActivityViewController(activityItems:[imgLoaded], applicationActivities:nil)
        
        if UI_USER_INTERFACE_IDIOM() != .Phone {
            activityVC.modalPresentationStyle = .Popover
            activityVC.preferredContentSize = CGSizeMake(320,400)
            let popoverVC = activityVC.popoverPresentationController
            popoverVC?.sourceView = imgView
            let touchPoint = longPress.locationInView(self.imgView)
            popoverVC?.sourceRect = CGRectMake(touchPoint.x, touchPoint.y, 1, 1)
        }
        
        self.presentViewController(activityVC, animated:true, completion:nil)
    }
    
    // MARK: - Image Asset Retrieval
    
    func retrieveImageFromAsset() {
        guard let imgSrc = imgSrc as? PHAsset else {
            return
        }
        
        let reqOptions = PHImageRequestOptions()
        reqOptions.synchronous = true
        PHImageManager.defaultManager().requestImageDataForAsset(imgSrc, options:reqOptions) {
            (imageData, dataUTI, orientation, info) in
            
            if let imageData = imageData {
                self.imgLoaded = UIImage(data: imageData)
                self.addImageToScrollView()
            }
        }
    }
    
    func retrieveImageFromURL() {
        guard let url = imgSrc as? NSURL else {
            return
        }
        
        imageRetriever.retrieveImageFromURL(url, progressCallback: {
            progress in
            
            dispatch_async(dispatch_get_main_queue()) {
                self.progressView?.progress = CGFloat(progress)
            }
            
            }, completionCallback: {
                (image, error) in
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let error = error {
                        self.progressView?.removeFromSuperview()
                        NSLog("error %@", error)
                        self.showError()
                        return
                    } else {
                        self.imgLoaded = image
                        self.addImageToScrollView()
                        self.progressView?.removeFromSuperview()
                    }
                }
        })
    }
    
    // MARK: - Misc. Methods
    
    @objc func dismissUI() {
        NSNotificationCenter.defaultCenter().postNotificationName("DismissUI", object:nil)
    }
    
    func showError() {
        let controller = UIAlertController(title:"Whoops", message:"Looks like we ran into an issue loading the image, sorry about that!", preferredStyle: .Alert)
        
        let closeAction = UIAlertAction(title:"Ok", style: .Default) {
            _ in
            
            NSNotificationCenter.defaultCenter().postNotificationName("ImageLoadingError", object:nil)
        }
        controller.addAction(closeAction)
        
        self.presentViewController(controller, animated:true, completion:nil)
    }
}

extension BufferImageContainerViewController: UIScrollViewDelegate {
    
    // MARK: - Scrollview Delegate
    
    @objc func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.scrollView.subviews.first
    }
    
    @objc func scrollViewDidZoom(scrollView: UIScrollView) {
        self.animator.removeAllBehaviors()
        self.centerScrollViewContents()
    }
    
    // MARK: - Scrollview Util Methods
    
    /*! This calculates the correct zoom scale for the scrollview once we have the image's size */
    func setMaxMinZoomScalesForCurrentBounds() {
        guard let imgView = imgView else { return }
        
        // Sizes
        let boundsSize = self.scrollView.bounds.size
        let imageSize  = imgView.frame.size
        
        // Calculate Min
        let xScale   = boundsSize.width / imageSize.width
        let yScale   = boundsSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        
        // Calculate Max
        var maxScale:CGFloat = 4.0
        //        if UIScreen.respondsToSelector(#selector(scale)) {
        maxScale = maxScale / UIScreen.mainScreen().scale
        
        if maxScale < minScale {
            maxScale = minScale * 2;
        }
        //        }
        
        //Apply zoom
        self.scrollView.maximumZoomScale = maxScale
        self.scrollView.minimumZoomScale = minScale
        self.scrollView.zoomScale = minScale
    }
    
    /*! Called during zooming of the image to ensure it stays centered */
    func centerScrollViewContents() {
        guard let imgView = imgView else { return }
        
        let boundsSize = self.scrollView.bounds.size
        var contentsFrame = imgView.frame
        
        if (contentsFrame.size.width < boundsSize.width) {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        self.imgView?.frame = contentsFrame
    }
    
    /*! Called when an image is double tapped. Either zooms out or to specific point */
    @objc func recenterImageOriginOrZoomToPoint(tap: UITapGestureRecognizer) {
        if self.scrollView.zoomScale == self.scrollView.maximumZoomScale {
            //Zoom out since we zoomed in here
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated:true)
        } else {
            //Zoom to a point
            let touchPoint = tap.locationInView(self.scrollView)
            self.scrollView.zoomToRect(CGRectMake(touchPoint.x, touchPoint.y, 1, 1), animated:true)
        }
    }
    
}

extension BufferImageContainerViewController: UIGestureRecognizerDelegate {
    
    // MARK: - Gesture Recognizer Delegate
    
    //If we have more than one image, this will cancel out dragging horizontally to make it easy to navigate between images
    @objc func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        
        let velocity = gestureRecognizer.velocityInView(self.scrollView)
        return fabs(velocity.y) > fabs(velocity.x)
    }
    
}

