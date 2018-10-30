//
//  NavigationSettings.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/30/18.
//

import Foundation

@objc public class FeatureFlagsViewControllerNavigationSettings: NSObject {
    let animated: Bool
    let autoClose: Bool
    let isNavigationBarHidden: Bool
    
    init(animated: Bool, autoClose: Bool, isNavigationBarHidden: Bool) {
        self.animated = animated
        self.autoClose = autoClose
        self.isNavigationBarHidden = isNavigationBarHidden
    }
}
