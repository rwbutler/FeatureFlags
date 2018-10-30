//
//  ViewController.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/18/2018.
//  Copyright (c) 2018 Ross Butler. All rights reserved.
//

import UIKit
import FeatureFlags

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let feature = Feature.named(.exampleFeatureOnOffTest) {
            print("Feature name -> \(feature.name)")
            print("Is enabled? -> \(feature.isEnabled())")
            print("Is in group A? -> \(feature.isTestVariation(.enabled))")
            print("Is in group B? -> \(feature.isTestVariation(.disabled))")
            print("Test variation -> \(feature.testVariation())")
        }
        if let test = ABTest(rawValue: .exampleABTest) {
            print("Is in group A? -> \(test.isGroupA())")
            print("Is in group B? -> \(test.isGroupB())")
        }
        
        print(Feature.isEnabled(.exampleABTest))
        
    }

}

