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
@objc @MainActor class LiveTextManager: NSObject, ImageAnalysisInteractionDelegate {
    private let interaction = ImageAnalysisInteraction()
    private let analyzer = ImageAnalyzer()
    private let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode])
    private var analyzedImage: UIImage? = nil
    
    override init() {
        super.init()
        interaction.delegate = self
    }
    
    @objc
    static func isLiveTextAvailable() -> Bool {
        return ImageAnalyzer.isSupported
    }
    
    @objc
    func analyzeImageView(view: UIView, image: UIImage) {
        if let inFlightView = interaction.view {
            inFlightView.removeInteraction(interaction)
        }
        
        Task {
            interaction.analysis = nil
            interaction.preferredInteractionTypes = []
            analyzedImage = image
            
            if let analysis = try? await analyzer.analyze(image, configuration: configuration) {
                if analyzedImage == image && (analysis.hasResults(for: .text) || analysis.hasResults(for: .machineReadableCode)) {
                    view.addInteraction(interaction)
                    interaction.analysis = analysis
                    interaction.preferredInteractionTypes = .automatic
                }
            }
        }
    }
    
    @objc func hasLiveTextInteractionAt(point: CGPoint) -> Bool {
        return interaction.hasInteractiveItem(at: point) || interaction.hasActiveTextSelection
    }
    
    @objc func updateContentRect() {
        interaction.setContentsRectNeedsUpdate()
    }
    
    // MARK: Delegate
    
    nonisolated func interaction(_ interaction: ImageAnalysisInteraction, shouldBeginAt point: CGPoint, for interactionType: ImageAnalysisInteraction.InteractionTypes) -> Bool {
        return hasLiveTextInteractionAt(point: point)
    }
}
