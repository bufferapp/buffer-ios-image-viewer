//
//  BufferImageContainerViewController+SDWebImage.swift
//  BFRImageViewer
//
//  Created by Jordan Morgan on 11/10/15.
//

import Foundation
import UIKit
import class SDWebImage.SDWebImageManager
import struct SDWebImage.SDWebImageOptions

/**
 *  Simple adapter for SDWebImageManager to work as the default BufferImageRetriever.
 */
struct SDImageRetriever: BufferImageRetriever {
    
    // MARK: - Image Asset Retrieval
    
    func retrieveImageFromURL(url: NSURL, progressCallback: (Double) -> Void, completionCallback: (UIImage?, NSError?) -> Void) {
        
        let manager = SDWebImageManager.sharedManager()
        manager.downloadImageWithURL(url, options: SDWebImageOptions.init(rawValue: 0), progress: {
            (receivedSize, expectedSize) in
            
            let fractionCompleted = Double(receivedSize / expectedSize)
            progressCallback(fractionCompleted)
            
            }, completed: {
                (image, error, cacheType, finished, imageURL) in
                
                completionCallback(image, error)
        })
    }
    
}

extension BufferImageViewController {
    
    convenience public init(imageSource images: [AnyObject]) {
        self.init(imageSource: images, imageRetriever: SDImageRetriever())
    }
    
    /*! Initializes an instance of @C BFRImageViewController from the image source provided. The array can contain a mix of @c NSURL, @c UIImage, @c PHAsset, or @c NSStrings of URLS. This can be a mix of all these types, or just one. Additionally, this customizes the user interface to defer showing some of its user interface elements, such as the close button, until it's been fully popped.*/
    convenience public init(forPeekWithImageSource images: [AnyObject]) {
        self.init(forPeekWithImageSource: images, imageRetriever: SDImageRetriever())
    }
}

