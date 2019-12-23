//
//  CollectionAdditions.swift
//  FeatureFlags
//
//  Created by Ross Butler on 23/12/2019.
//

import Foundation

extension Collection {
    
    func element(at index: Self.Index) -> Self.Iterator.Element? {
        if endIndex > index && startIndex <= index {
            return self[index]
        } else {
            return nil
        }
    }
    
    public func mapDistinct<T: Equatable>(_ transform: (Iterator.Element) throws -> T
        ) rethrows -> [T] {
        
        let count: Int = numericCast(self.count)
        if isEmpty {
            return []
        }
        
        var result = ContiguousArray<T>()
        result.reserveCapacity(count)
        
        var i = self.startIndex
        
        for _ in 0..<count {
            let transformed = try transform(self[i])
            if !result.contains(where: { $0 == transformed }) {
                result.append(transformed)
            }
            formIndex(after: &i)
        }
        return Array(result)
    }
    
}
