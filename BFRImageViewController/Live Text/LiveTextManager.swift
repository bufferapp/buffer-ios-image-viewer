//
//  LiveTextManager.swift
//  BFRImageViewer
//
//  Created by Jordan Morgan on 7/12/22.
//  Copyright © 2022 Andrew Yates. All rights reserved.
//

import Foundation
import VisionKit

@available(iOS 16.0, *)
@objc @MainActor class LiveTextManager: NSObject {
    private var interaction = ImageAnalysisInteraction()
    
    @objc
    static func isLiveTextAvailable() -> Bool {
        return ImageAnalyzer.isSupported
    }
    
    @objc
    func analyzeImageView(view: UIView, image: UIImage) async {
        interaction = ImageAnalysisInteraction()
        interaction.preferredInteractionTypes = .automatic
        view.addInteraction(interaction)
        
        let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode])
        let analyzer = ImageAnalyzer()
        let analysis = try? await analyzer.analyze(image, configuration: configuration)
        interaction.analysis = analysis
    }
}
