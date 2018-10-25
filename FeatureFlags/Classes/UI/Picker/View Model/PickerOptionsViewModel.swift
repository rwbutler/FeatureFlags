//
//  PickerOptionsViewModel.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/23/18.
//

import Foundation

struct PickerOptionsViewModel<PickerOption: Equatable & CustomStringConvertible> {
    let pickerOptions: [PickerOption]
    var selectedIndex: Int
    
    init?(options: [PickerOption], selectedOption: Int) {
        guard 0..<options.count ~= selectedOption else {
            return nil
        }
        self.pickerOptions = options
        self.selectedIndex = selectedOption
    }
    
    func selectedOption() -> PickerOption {
        return pickerOptions[selectedIndex]
    }
}
