/*
 
 Project: Octopus
 File: Array+Parallel+Filter.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
 Status: #Completed | #Not decorated
 
*/

import Foundation

extension Array.Parallel {
    public func filter(
        requiredNumber ofThreads: Int? = nil,
        priority: DispatchQoS.QoSClass = .userInteractive,
        _ isIncluded: @escaping (Element) throws -> Bool
    ) rethrows -> [Element]{
        
        return try _filter(requiredNumber: ofThreads, priority: priority, isIncluded: isIncluded, rethrow)
        
        func rethrow(error: Error) throws ->() {
            throw error
        }
        
        func _filter(
            requiredNumber threads: Int?,
            priority: DispatchQoS.QoSClass,
            isIncluded: @escaping (Element) throws -> Bool,
            _ rethrow: (_ error: Error) throws -> ()
        ) rethrows -> [Element]
        {
            if self.array.isEmpty {
                return []
            }
            var storage: [Int: [Element]] = [:]
            let group = DispatchGroup()
            var errors: [(String, Error)] = []
            
            self.parallelize(amountThreads: self.amountThreads(threads), group: group) { [weak self] iteration, slice in
                guard let parallel = self else {
                    let message = "The instance was freed at run time. "
                    let ps = "P/S I don’t know how you did it, but if it happened, please share in the GitHub thread :-)"
                    errors.append((message + ps, OctopusError.unexpectedState))
                    group.leave()
                    return
                }
                do {
                    let output = try parallel.array[slice].filter(isIncluded)
                    parallel.insertQueue.async {
                        storage[iteration] = output
                        group.leave()
                    }
                } catch {
                    parallel.insertQueue.async {
                        errors.append(("element: \(Element.self), slice: \(slice)", error))
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
            
            return storage.sorted(by: { $0.0 < $1.0 }).flatMap { $0.1 }
        }
    }
}
