/*
 
 Project: Octopus
 File: Array+Parallel+Method+Map.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
 Status: #Completed | #Not decorated
 
*/

import Foundation

extension Array.Parallel {
    public func map<T>(
        requiredNumber threads: Int? = nil,
        priority: DispatchQoS.QoSClass = .userInteractive,
        _ transform: @escaping (Element) throws -> T
    ) rethrows -> [T]{
        
        return try _map(requiredNumber: threads, priority: priority, transform: transform, rethrow)
        
        func rethrow(error: Swift.Error) throws ->() {
            throw error
        }
        
        func _map<T>(
            requiredNumber threads: Int?,
            priority: DispatchQoS.QoSClass,
            transform: @escaping (Element) throws -> T,
            _ rethrow: (_ error: Swift.Error) throws -> ()
        ) rethrows -> [T] {
            if self.array.isEmpty {
                return []
            }
            var storage: [Int: [T]] = [:]
            let group = DispatchGroup()
            var errors: [(String, Swift.Error)] = []
            
            self.parallelize(amountThreads: self.amountThreads(threads), group: group, priority: priority) { [weak self] iteration, slice in
                guard let parallel = self else {
                    errors.append((Self.instanceWasFreedMessage, OctopusError.unexpectedState))
                    group.leave()
                    return
                }
                do {
                    let output = try parallel.array[slice].map(transform)
                    parallel.insertQueue.async {
                        storage[iteration] = output
                        group.leave()
                    }
                } catch {
                    parallel.insertQueue.async {
                        let message = "method: map, element: \(Element.self), slice: \(slice)"
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
    public func map<T>(
        requiredNumber threads: Int? = nil,
        priority: DispatchQoS.QoSClass = .userInteractive,
        _ transform: @escaping (Element) throws -> T
    ) async throws -> [T]{
        try await withCheckedThrowingContinuation{ continuation in
            do {
                let result = try self.map(requiredNumber: threads, priority: priority, transform)
                continuation.resume(returning: result)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

//MARK: async
extension Array.Parallel {
    public func map<T>(
        requiredNumber threads: Int? = nil,
        priority: DispatchQoS.QoSClass = .userInteractive,
        _ transform: @escaping (Element) -> T
    ) async -> [T]{
        await withCheckedContinuation{ continuation in
            let result = self.map(requiredNumber: threads, priority: priority, transform)
            continuation.resume(returning: result)
        }
    }
}