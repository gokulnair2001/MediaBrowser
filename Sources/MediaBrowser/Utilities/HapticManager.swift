//
//  HapticManager.swift
//  MediaBrowser
//
//  Created by Gokul Nair(Work) on 30/10/24.
//


import UIKit

class HapticManager {
   
    public static var shared: HapticManager = {
        let shared = HapticManager()
        return shared
    }()
    
    private init(){}
    
    func giveHapticFeedbackForSelectionChanged() {
        DispatchQueue.main.async {
            let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
            selectionFeedbackGenerator.prepare()
            selectionFeedbackGenerator.selectionChanged()
        }
    }
    
    func giveLightImpactFeedback() {
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}
