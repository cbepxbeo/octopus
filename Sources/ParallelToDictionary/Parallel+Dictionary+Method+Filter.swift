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
    ///Returns a new dictionary containing the key-value pairs of the dictionary that satisfy the given predicate.
    ///
    /// This example uses filter(_:) example that gives a performance boost.
    /// ```
    /// let arrayA: [Int] = .init(repeating: 10, count: 100)
    /// let arrayB: [Int] = .init(repeating: 20, count: 100)
    ///
    /// var dictionary: [Int: [Int]] = [:]
    /// for item in 0...1000 {
    ///     dictionary[item] = item % 2 == 0 ? arrayA : arrayB
    /// }
    ///
    /// let result = dictionary.parallel().filter {
    ///     $0.value.reduce(0) { $0 + $1 } > 1000
    /// }
    /// // Up to two times faster execution speed
    /// ```
    ///
    ///- Complexity: O(n), where n is the length of the sequence.
    ///- Parameters:
    ///     - requiredNumber:
    ///         Number of threads required to execute. Default active processor count.
    ///- Parameters:
    ///     - priority:
    ///         The priority with which work will be performed in multiple threads.
    ///- Parameters:
    ///     - isIncluded:
    ///         A closure that takes a key-value pair as its argument and returns a Boolean
    ///         value indicating whether the pair should be included in the returned dictionary.
    ///- Note: iteration will be performed by several threads.
    ///- Returns: A dictionary of the key-value pairs that isIncluded allows.
    ///- Warning: The use makes sense if the filter condition requires additional calculations, such as a nested loop.
    ///     Otherwise, single-threaded dictionary filtering will be faster because it doesn't require merging.
    ///     The efficiency of work in relation to the complexity of nested calculations is directly proportional
    ///     to the size of the dictionary - the larger the size, the less complexity is needed to satisfy the
    ///     conditions for achieving maximum performance.
    public func filter<Key: Hashable, Value>(
        requiredNumber threads: Int? = nil,
        priority: DispatchQoS.QoSClass = .userInteractive,
        _ isIncluded: @escaping ((key: Key, value: Value)) throws -> Bool
    ) rethrows -> [Key: Value] where StructureData == Dictionary<Key, Value> {
        
        return try _filter(requiredNumber: threads, priority: priority, isIncluded: isIncluded, rethrow)
        
        func rethrow(error: Error) throws ->() {
            throw error
        }
        
        func _filter(
            requiredNumber threads: Int?,
            priority: DispatchQoS.QoSClass,
            isIncluded: @escaping ((key: Key, value: Value)) throws -> Bool,
            _ rethrow: (_ error: Error) throws -> ()
        ) rethrows -> [Key: Value] {
            if self.structureData.isEmpty {
                logger.debug("Structure data (Dictionary) - empty")
                return [:]
            }
            
            if self.structureData.count < self.amountThreads(threads) * 2 {
                logger.debug("Not enough for parallel computing")
                return try structureData.filter(isIncluded)
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
                    let output = try slice.filter(isIncluded)
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


//MARK: async with throws
extension Parallel {
    ///Asynchronously returns a new dictionary containing the key-value pairs of the dictionary that satisfy the given predicate, with the ability to handle errors.
    ///
    /// This example uses filter(_:) return an error.
    /// ```
    /// let arrayA: [Int] = .init(repeating: 10, count: 100)
    /// let arrayB: [Int] = .init(repeating: 20, count: 100)
    ///
    /// var dictionary: [Int: [Int]] = [:]
    /// for item in 0...1000 {
    ///     dictionary[item] = item % 2 == 0 ? arrayA : arrayB
    /// }
    ///
    /// do {
    ///     let result = try await dictionary.parallel().filter {
    ///         if $0.value.reduce(0, { $0 + $1 }) > 1000 {
    ///             throw MyError.example
    ///         } else {
    ///             return true
    ///         }
    ///     }
    /// } catch {
    ///     print(error)
    ///     //Prints all errors
    /// }
    ///
    /// ```
    /// This example uses filter(_:) example that gives a performance boost.
    /// ```
    /// do {
    ///     let result = try await dictionary.parallel().filter {
    ///         if $0.value.reduce(0, { $0 + $1 }) == 0 {
    ///             throw MyError.example
    ///         } else {
    ///             return true
    ///         }
    ///     }
    /// } catch {
    ///     // .. will never be fulfilled
    /// }
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
    ///         A closure that takes a key-value pair as its argument and returns a Boolean
    ///         value indicating whether the pair should be included in the returned dictionary.
    ///- Note: iteration will be performed by several threads.
    ///- Returns: A dictionary of the key-value pairs that isIncluded allows.
    ///- Warning: The use makes sense if the filter condition requires additional calculations, such as a nested loop.
    ///     Otherwise, single-threaded dictionary filtering will be faster because it doesn't require merging.
    ///     The efficiency of work in relation to the complexity of nested calculations is directly proportional
    ///     to the size of the dictionary - the larger the size, the less complexity is needed to satisfy the
    ///     conditions for achieving maximum performance.
    public func filter<Key: Hashable, Value>(
        requiredNumber threads: Int? = nil,
        priority: DispatchQoS.QoSClass = .userInteractive,
        _ isIncluded: @escaping ((key: Key, value: Value)) throws -> Bool
    ) async throws -> [Key: Value] where StructureData == Dictionary<Key, Value> {
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
extension Parallel {
    ///Asynchronously returns a new dictionary containing the key-value pairs of the dictionary that satisfy the given predicate.
    ///
    /// This example uses filter(_:) example that gives a performance boost.
    /// ```
    /// let arrayA: [Int] = .init(repeating: 10, count: 100)
    /// let arrayB: [Int] = .init(repeating: 20, count: 100)
    ///
    /// var dictionary: [Int: [Int]] = [:]
    /// for item in 0...1000 {
    ///     dictionary[item] = item % 2 == 0 ? arrayA : arrayB
    /// }
    ///
    /// let result = await dictionary.parallel().filter {
    ///     $0.value.reduce(0) { $0 + $1 } > 1000
    /// }
    /// // Up to two times faster execution speed
    /// ```
    ///
    ///- Complexity: O(n), where n is the length of the sequence.
    ///- Parameters:
    ///     - requiredNumber:
    ///         Number of threads required to execute. Default active processor count.
    ///- Parameters:
    ///     - priority:
    ///         The priority with which work will be performed in multiple threads.
    ///- Parameters:
    ///     - isIncluded:
    ///         A closure that takes a key-value pair as its argument and returns a Boolean
    ///         value indicating whether the pair should be included in the returned dictionary.
    ///- Note: iteration will be performed by several threads.
    ///- Returns: A dictionary of the key-value pairs that isIncluded allows.
    ///- Warning: The use makes sense if the filter condition requires additional calculations, such as a nested loop.
    ///     Otherwise, single-threaded dictionary filtering will be faster because it doesn't require merging.
    ///     The efficiency of work in relation to the complexity of nested calculations is directly proportional
    ///     to the size of the dictionary - the larger the size, the less complexity is needed to satisfy the
    ///     conditions for achieving maximum performance.
    public func filter<Key: Hashable, Value>(
        requiredNumber threads: Int? = nil,
        priority: DispatchQoS.QoSClass = .userInteractive,
        _ isIncluded: @escaping ((key: Key, value: Value)) -> Bool
    ) async -> [Key: Value] where StructureData == Dictionary<Key, Value> {
        await withCheckedContinuation{ continuation in
            let result = self.filter(requiredNumber: threads, priority: priority, isIncluded)
            continuation.resume(returning: result)
        }
    }
}
