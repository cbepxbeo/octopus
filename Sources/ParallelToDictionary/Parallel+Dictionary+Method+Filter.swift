/*
 
 Project: Octopus
 File: Parallel+Dictionary+Method+Filter.swift
 Created by: Egor Boyko
 Date: 06.04.2023
 
 Status: #In progress | #Not decorated
 
*/

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
                logger.debug("Structure data (Dictionary) - empty")
                return [:]
            }
            
            if self.structureData.count < self.amountThreads(threads) * 2 {
                logger.debug("Not enough for parallel computing")
                return try structureData.filter{ try isIncluded($0.0) }
            }
            
            var result: Dictionary<Key, Value> = [:]
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
                    let output = try slice.filter{ try isIncluded($0.key) }
                    parallel.insertQueue.async {
                        result.merge(output) { (current, _) in current }
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
            
            return result
        }
    }
}
