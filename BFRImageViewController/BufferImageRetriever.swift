//
//  BufferCacheManager.swift
//  BFRImageViewer
//
//  Created by Jordan Morgan on 11/10/15.
//
//

import Foundation
import UIKit

/**
 *  Protocol designed to abstract the fetchFromURL operation from the ViewController itself.
 */
public protocol BufferImageRetriever {
    
    /**
     Retrieves, if possible, an image from an URL.
    
     - parameter url:                URL which points to an image.
     - parameter progressCallback:   Called during the operation to inform download progress (fraction).
     - parameter completionCallback: Called when the operation ends.
     */
    func retrieveImageFromURL(url: NSURL, progressCallback: (Float) -> Void, completionCallback: (UIImage?, NSError?) -> Void)
}
