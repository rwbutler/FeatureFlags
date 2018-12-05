//
//  FeatureFlagsObserver.swift
//  FeatureFlags
//
//  Created by Ross Butler on 12/5/18.
//

import Foundation

@objc class FeatureFlagsUIObserver: NSObject {
    
    @objc func willEnterForeground(_ notification: Notification) {
        if FeatureFlagsUI.autoRefresh && notification.name == UIApplication.willEnterForegroundNotification {
            FeatureFlags.refresh()
        }
    }

}
