//
//  UIControl.swift
//  FeatureFlags
//
//  Created by Ross Butler on 22/03/2023.
//

import Foundation
import ObjectiveC

public extension NSObject {
    func associatedObject<T>(key: UnsafeRawPointer, makeDefault: () -> T) -> T {
        if let result = objc_getAssociatedObject(self, key) as? T {
            return result
        }
        let result = makeDefault()
        objc_setAssociatedObject(self, key, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return result
    }
}

public func configure<T>(_ value: T, using closure: (inout T) throws -> Void) rethrows -> T {
    var value = value
    try closure(&value)
    return value
}

public final class TouchActionHandler: NSObject {
    public var action: () -> Void = {}
    @objc func didTouch() {
        action()
    }
}

private var touchUpInsideHandlerKey: Int?

public extension UIControl {
    var touchUpInside: TouchActionHandler {
        associatedObject(key: &touchUpInsideHandlerKey) {
            configure(TouchActionHandler()) {
                self.addTarget($0, action: #selector(TouchActionHandler.didTouch), for: .touchUpInside)
            }
        }
    }
}
