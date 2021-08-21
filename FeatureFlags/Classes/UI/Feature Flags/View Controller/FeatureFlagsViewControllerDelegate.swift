//
//  FeatureFlagsViewControllerDelegate.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/30/18.
//

import Foundation

@objc public protocol FeatureFlagsViewControllerDelegate: AnyObject {
    @objc func viewControllerDidFinish()
}
