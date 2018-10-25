//
//  ParsingService.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/19/18.
//

import Foundation

protocol ParsingService {
    func parse(_ data: Data) -> ParsingServiceResult?
}
