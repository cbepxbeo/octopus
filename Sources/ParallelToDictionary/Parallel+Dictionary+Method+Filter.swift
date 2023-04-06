//
//  File.swift
//  
//
//  Created by Егор Бойко on 06.04.2023.
//

import Foundation

import OSLog

fileprivate let logger: Logger = .init(
    subsystem: "octopus",
    category: "parallel-dictionary-method-filter"
)

extension Parallel {
    
    public func filter<Key: Hashable, Value>(
        requiredNumber threads: Int? = nil,
        priority: DispatchQoS.QoSClass = .userInteractive,
        _ isIncluded: @escaping (Key) throws -> Bool
    ) rethrows -> [Key: Value] where StructureData == Dictionary<Key, Value> {
        
        return try _filter(requiredNumber: threads, priority: priority, isIncluded: isIncluded, rethrow)
        
        func rethrow(error: Error) throws ->() {
            throw error
        }
        
        func _filter(
            requiredNumber threads: Int?,
            priority: DispatchQoS.QoSClass,
            isIncluded: @escaping (Key) throws -> Bool,
            _ rethrow: (_ error: Error) throws -> ()
        ) rethrows -> [Key: Value] {
            if self.structureData.isEmpty {
                return [:]
            }
            
            if self.structureData.count < self.amountThreads(threads) * 2 {
                logger.debug("Not enough for parallel computing")
                return try structureData.filter{ try isIncluded($0.0) }
            }
            
            var storage: [Int: [Key: Value]] = [:]
            var array: [(Key, Value)] = []
            
            for (key, value) in self.structureData {
                array.append((key, value))
            }
    
            let group = DispatchGroup()
            var errors: [(String, Error)] = []
            
            self.parallelize(amountThreads: self.amountThreads(threads), group: group, priority: priority) { [weak self] iteration, slice in
                guard let parallel = self else {
                    errors.append((Self.instanceWasFreedMessage, OctopusError.unexpectedState))
                    group.leave()
                    return
                }
                do {
                    let output = try array[slice].filter{ try isIncluded($0.0) }
                    let dictoinary = Dictionary(output, uniquingKeysWith: { (first, _) in first })
                    parallel.insertQueue.async {
                        storage[iteration] = dictoinary
                        group.leave()
                    }
                } catch {
                    parallel.insertQueue.async {
                        let message = "method: filter, element: \(Element.self), slice: \(slice)"
                        errors.append((message, error))
                        group.leave()
                    }
                }
            }
            group.wait()
            
            if !errors.isEmpty {
                if errors.count > 1 {
                    try rethrow(OctopusError.multiple(errors: errors))
                } else if let first = errors.first {
                    try rethrow(OctopusError.alone(message: first.0, error: first.1))
                }
            }
            return storage.reduce([:], { x, y in
                var temp = x
                temp.merge(y.value){ (current, _) in current }
                return temp
            })
        }
    }
}
