//
//  NavigationSettings.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/30/18.
//

import Foundation
import UIKit

@objc public class FeatureFlagsViewControllerNavigationSettings: NSObject {
    let animated: Bool
    let autoClose: Bool
    let closeButtonAlignment: FeatureFlagsViewControllerCloseButtonAlignment
    let closeButton: UIBarButtonItem.SystemItem
    let isModal: Bool
    let isNavigationBarHidden: Bool
    let shouldRefresh: Bool
    
    public init(animated: Bool = false, autoClose: Bool = true, closeButtonAlignment: FeatureFlagsViewControllerCloseButtonAlignment = .left, closeButton: UIBarButtonItem.SystemItem = .done, isModal: Bool = false, isNavigationBarHidden: Bool = false, shouldRefresh: Bool = true) {
        self.animated = animated
        self.autoClose = autoClose
        self.closeButtonAlignment = closeButtonAlignment
        self.closeButton = closeButton
        self.isModal = isModal
        self.isNavigationBarHidden = isNavigationBarHidden
        self.shouldRefresh = shouldRefresh
    }
}
