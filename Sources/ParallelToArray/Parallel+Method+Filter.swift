/*
 
 Project: Octopus
 File: Parallel+Method+Filter.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
 Status: #Completed | #Not decorated
 
 */

import Foundation

//MARK: Default
extension Parallel where StructureData == Array<Element> {
    ///Returns an array containing, in order, the elements of the sequence that satisfy the given predicate.
    ///
    /// This example uses filter(_:) to include only values greater than twenty-one.
    /// ```
    /// let exampleArray: [Int] = [5, 8, 13, 21, 34, 55, 89 ]
    /// let result = exampleArray.parallel().filter{ $0 > 21 }
    /// print(result)
    /// // Prints "[34, 55, 89]"
    /// ```
    ///- Complexity: O(n), where n is the length of the sequence.
    ///- Parameters:
    ///     - requiredNumber:
    ///         Number of threads required to execute. Default active processor count.
    ///- Parameters:
    ///     - priority:
    ///         The priority with which work will be performed in multiple threads.
    ///- Parameters:
    ///     - isIncluded:
    ///         A closure that takes an element of the sequence as its argument and returns a Boolean
    ///         value indicating whether the element should be included in the returned array.
    ///- Note: iteration will be performed by several threads.
    ///- Returns: An array of the elements that isIncluded allowed.
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
            if self.structureData.isEmpty {
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
                    let output = try parallel.structureData[slice].filter(isIncluded)
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
extension Parallel where StructureData == Array<Element> {
    ///Asynchronously Returns an array containing, in order, the elements of a sequence that satisfy the given predicate, with the ability to handle errors.
    ///
    /// This example uses filter(_:) return an error.
    /// ```
    /// let exampleArray: [Int] = [5, 8, 13, 21, 34, 55, 89 ]
    /// do {
    ///     let result = try await self.exampleArray.parallel().filter{ item throws -> Bool in
    ///         if item == 55 {
    ///             throw MyError.example
    ///         } else {
    ///              return item > 21
    ///         }
    ///     }
    /// }
    /// catch {
    ///     print(error)
    ///     // Prints "example"
    /// }
    /// ```
    /// This example uses filter(_:) to include only values greater than twenty-one.
    /// ```
    /// let exampleArray: [Int] = [5, 8, 13, 21, 34, 55, 89 ]
    /// do {
    ///     let result = try await self.exampleArray.parallel().filter{ item throws -> Bool in
    ///         if item == 0 {
    ///             throw MyError.example
    ///         } else {
    ///              return item > 21
    ///         }
    ///     }
    ///     print(result)
    ///     // Prints "[34, 55, 89]"
    /// }
    /// catch {
    ///     // .. will never be fulfilled
    /// }
    /// ```
    ///- Complexity: O(n), where n is the length of the sequence.
    ///- Note: iteration will be performed by several threads.
    ///- Parameters:
    ///     - requiredNumber:
    ///         Number of threads required to execute. Default active processor count.
    ///- Parameters:
    ///     - priority:
    ///         The priority with which work will be performed in multiple threads.
    ///- Parameters:
    ///     - isIncluded:
    ///         A closure that takes an element of the sequence as its argument and returns a Boolean
    ///         value indicating whether the element should be included in the returned array.
    ///- Returns: An array of the elements that isIncluded allowed.
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
extension Parallel where StructureData == Array<Element> {
    ///Asynchronously Returns an array containing, in order, the elements of a sequence that satisfy the given predicate.
    ///
    /// This example uses filter(_:) to include only values greater than twenty-one.
    /// ```
    /// let exampleArray: [Int] = [5, 8, 13, 21, 34, 55, 89 ]
    /// let result = await self.exampleArray.parallel().filter{ $0 > 21 }
    /// // Prints "[34, 55, 89]"
    /// ```
    ///- Complexity: O(n), where n is the length of the sequence.
    ///- Note: iteration will be performed by several threads.
    ///- Parameters:
    ///     - requiredNumber:
    ///         Number of threads required to execute. Default active processor count.
    ///- Parameters:
    ///     - priority:
    ///         The priority with which work will be performed in multiple threads.
    ///- Parameters:
    ///     - isIncluded:
    ///         A closure that takes an element of the sequence as its argument and returns a Boolean
    ///         value indicating whether the element should be included in the returned array.
    ///- Returns: An array of the elements that isIncluded allowed.
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
