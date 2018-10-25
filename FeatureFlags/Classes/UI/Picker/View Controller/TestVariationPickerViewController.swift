//
//  TestVariationPickerViewController.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/23/18.
//

import Foundation
import UIKit

class TestVariationPickerViewController: PickerViewController<Test.Variation> {
    override var selection: PickerItemTapped? {
        get { return super.selection }
        set { super.selection = newValue }
    }
    override var viewModel: [String: PickerOptionsViewModel<Test.Variation>]? {
        get { return super.viewModel }
        set { super.viewModel = newValue }
    }
}
