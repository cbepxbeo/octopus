/*
 
 Project: ParallelSequence
 File: Array+Parallel.swift
 Created by: Egor Boyko
 Date: 02.04.2023
 
 Status: #In progress | #Not decorated
 
*/

import Foundation

//MARK: Array.Parallel
extension Array {
    public final class Parallel<Element> {
        internal init(array: [Element]){}
    }
}

//MARK: Public Methods
extension Array.Parallel {
    public func filter(
        requiredNumber ofThreads: Int? = nil,
        priority: DispatchQoS.QoSClass = .userInteractive,
        isIncluded: @escaping (Element) throws -> Bool
    ) rethrows -> [Element]{
        
        return try _filter(requiredNumber: ofThreads, priority: priority, isIncluded: isIncluded, rethrow)
        
        func rethrow(error: Swift.Error) throws ->() {
            throw error
        }
        
        func _filter(
            requiredNumber threads: Int?,
            priority: DispatchQoS.QoSClass,
            isIncluded: @escaping (Element) throws -> Bool,
            _ rethrow: (_ error: Swift.Error) throws -> ()
        ) rethrows -> [Element]
        {
            if self.array.isEmpty {
                return []
            }
            var storage: [Int: [Element]] = [:]
            let group = DispatchGroup()
            var errors: [(String, Swift.Error)] = []
            
            self.parallelize(amountThreads: self.amountThreads(threads), group: group) { [weak self] iteration, slice in
                guard let parallel = self else {
                    let message = "The instance was freed at run time. "
                    let ps = "P/S I don’t know how you did it, but if it happened, please share in the GitHub thread :-)"
                    errors.append((message + ps, Array.Parallel<Element>.Error.unexpectedState))
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
                    try rethrow(Array.Parallel<Element>.Error.multiple2(errors: errors))
                } else if let first = errors.first {
                    try rethrow(Array.Parallel<Element>.Error.alone2(message: first.0, error: first.1))
                }
            }
            
            return storage.sorted(by: { $0.0 < $1.0 }).flatMap { $0.1 }
        }
}

//MARK: Private Methods
extension Array.Parallel {
    private func amountThreads(_ amount: Int?) -> Int {
        if let amount {
            return amount > 6 ? 6 : amount < 2 ? 2 : amount
        }
        return self.amountThreads
    }
    
    private func parallelize(
        amountThreads: Int,
        group: DispatchGroup,
        _ action: @escaping (_ iteration: Int, _ slice: ClosedRange<Int>) -> ()){
        for currentIteration in 1...amountThreads {
            let startIndex = self.sliceData.step * (currentIteration - 1)
            let endIndex = currentIteration == amountThreads ?
            ((self.sliceData.step * currentIteration) + self.sliceData.remainder - 1) :
            ((self.sliceData.step * currentIteration) - 1)
            group.enter()
            DispatchQueue.global(qos: .userInteractive).async {
                action(currentIteration, startIndex...endIndex)
            }
        }
    }
}
