//
//  FeatureFlagTableViewCell.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/19/18.
//

import Foundation

class FeatureFlagTableViewCell: UITableViewCell {
    @IBOutlet weak var featureName: UILabel!
    @IBOutlet weak var featureDescription: UILabel!
    @IBOutlet weak var featureType: UILabel!
    @IBOutlet weak var featureEnabled: UISwitch!
    @IBOutlet weak var testVariation: UILabel!
    @IBOutlet weak var iconView: UIImageView!
}
