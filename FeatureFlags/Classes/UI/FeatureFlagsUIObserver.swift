//
//  FeatureFlagsObserver.swift
//  FeatureFlags
//
//  Created by Ross Butler on 12/5/18.
//

#if canImport(UIKit)
import Foundation
import UIKit

@objc class FeatureFlagsUIObserver: NSObject {
    
    @objc func willEnterForeground(_ notification: Notification) {
        if FeatureFlagsUI.autoRefresh && notification.name == UIApplication.willEnterForegroundNotification {
            FeatureFlags.refresh()
        }
    }

}
#endif
