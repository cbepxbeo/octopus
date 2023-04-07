/*
 
 Project: Octopus
 File: Parallel+Dictionary+Method+Map.swift
 Created by: Egor Boyko
 Date: 07.04.2023
 
 Status: #In progress | #Not decorated
 
*/

import Foundation
import OSLog

fileprivate let logger: Logger = .init(
    subsystem: "octopus",
    category: "parallel-dictionary-method-map"
)

extension Parallel {
    public func map<Key: Hashable, Value, T>(
        requiredNumber threads: Int? = nil,
        priority: DispatchQoS.QoSClass = .userInteractive,
        _ transform: @escaping ((key: Key, value: Value)) throws -> T
    ) rethrows -> [T] where StructureData == Dictionary<Key, Value> {
        
        return try _map(requiredNumber: threads, priority: priority, transform: transform, rethrow)
        
        func rethrow(error: Error) throws ->() {
            throw error
        }
        
        func _map(
            requiredNumber threads: Int?,
            priority: DispatchQoS.QoSClass,
            transform: @escaping ((key: Key, value: Value)) throws -> T,
            _ rethrow: (_ error: Error) throws -> ()
        ) rethrows -> [T] {
            if self.structureData.isEmpty {
                logger.debug("Structure data (Dictionary) - empty")
                return []
            }
            
            if self.structureData.count < self.amountThreads(threads) * 2 {
                logger.debug("Not enough for parallel computing")
                return try structureData.map(transform)
            }
            
            var storage: [T] = []
            let structureDataStartIndex = self.structureData.startIndex
            let group = DispatchGroup()
            var errors: [(String, Error)] = []
            
            self.parallelize(
                amountThreads: self.amountThreads(threads),
                group: group, priority: priority
            ) { [weak self] iteration, start, end in
                guard let parallel = self else {
                    errors.append((Self.instanceWasFreedMessage, OctopusError.unexpectedState))
                    group.leave()
                    return
                }
                let slice: Dictionary<Key, Value>.SubSequence
                let currentIndex = parallel.structureData.index(structureDataStartIndex, offsetBy: end)
                
                if iteration == 1 {
                    slice = parallel.structureData.prefix(parallel.sliceData.step)
                } else if iteration != parallel.amountThreads(threads) {
                    let temp = parallel.structureData.prefix(through: currentIndex)
                    slice = temp.suffix(parallel.sliceData.step)
                } else {
                    let temp = parallel.structureData.prefix(through: currentIndex)
                    slice = temp.suffix(parallel.sliceData.remainder + parallel.sliceData.step)
                }
                
                do {
                    let output = try slice.map(transform)
                    parallel.insertQueue.async {
                        storage += output
                        group.leave()
                    }
                }
                catch {
                    parallel.insertQueue.async {
                        let message = "Dictionary, method: filter, element: \(Element.self), iteration: \(iteration)"
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
            
            return storage
        }
    }
}
