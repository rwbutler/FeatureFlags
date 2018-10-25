//
//  JSONParsingService.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/19/18.
//

import Foundation

struct JSONParsingService: ParsingService {
    func parse(_ data: Data) -> ParsingServiceResult? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let jsonContainer = json as? [String: Any],
            let features = jsonContainer["features"],
            let featuresData = try? JSONSerialization.data(withJSONObject: features) else {
                let decoder = JSONDecoder()
                do {
                    let container = try decoder.decode([Feature].self, from: data)
                    return container
                } catch let e {
                    print(e)
                }
                return nil
        }
        let decoder = JSONDecoder()
        guard let container = try? decoder.decode([Feature].self, from: featuresData) else {
            return nil
        }
        return container
    }
}

