/*
 
 Project: Octopus
 File: Array+Parallel+Method+Filter..swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
 Status: #Completed | #Not decorated
 
 */

import Foundation

//MARK: Default
extension Array.Parallel {
    public func filter(
        requiredNumber threads: Int? = nil,
        priority: DispatchQoS.QoSClass = .userInteractive,
        _ isIncluded: @escaping (Element) throws -> Bool
    ) rethrows -> [Element]{
        
        return try _filter(requiredNumber: threads, priority: priority, isIncluded: isIncluded, rethrow)
        
        func rethrow(error: Error) throws ->() {
            throw error
        }
        
        func _filter(
            requiredNumber threads: Int?,
            priority: DispatchQoS.QoSClass,
            isIncluded: @escaping (Element) throws -> Bool,
            _ rethrow: (_ error: Error) throws -> ()
        ) rethrows -> [Element]{
            if self.array.isEmpty {
                return []
            }
            var storage: [Int: [Element]] = [:]
            let group = DispatchGroup()
            var errors: [(String, Error)] = []
            
            self.parallelize(amountThreads: self.amountThreads(threads), group: group, priority: priority) { [weak self] iteration, slice in
                guard let parallel = self else {
                    errors.append((Self.instanceWasFreedMessage, OctopusError.unexpectedState))
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
            
            return storage.sorted(by: { $0.0 < $1.0 }).flatMap { $0.1 }
        }
    }
}

//MARK: async with throws
extension Array.Parallel {
    public func filter(
        requiredNumber threads: Int? = nil,
        priority: DispatchQoS.QoSClass = .userInteractive,
        _ isIncluded: @escaping (Element) throws -> Bool
    ) async throws -> [Element]{
        try await withCheckedThrowingContinuation{ continuation in
            do {
                let result = try self.filter(requiredNumber: threads, priority: priority, isIncluded)
                continuation.resume(returning: result)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

//MARK: async
extension Array.Parallel {
    public func filter(
        requiredNumber threads: Int? = nil,
        priority: DispatchQoS.QoSClass = .userInteractive,
        _ isIncluded: @escaping (Element) -> Bool
    ) async -> [Element]{
        await withCheckedContinuation{ continuation in
            let result = self.filter(requiredNumber: threads, priority: priority, isIncluded)
            continuation.resume(returning: result)
        }
    }
}
