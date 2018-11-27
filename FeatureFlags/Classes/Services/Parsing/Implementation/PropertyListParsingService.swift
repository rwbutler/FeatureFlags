//
//  PropertyListParsingService.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/19/18.
//

import Foundation

struct PropertyListParsingService: ParsingService {
    func parse(_ data: Data) -> ParsingServiceResult? {
        let decoder = PropertyListDecoder()
        guard let features = try? decoder.decode([Feature].self, from: data) else {
            return nil
        }
        return features
    }
}
