/*
 
 Project: Octopus
 File: Array+Parallel.swift
 Created by: Egor Boyko
 Date: 02.04.2023
 
 Status: #In progress | #Not decorated
 
*/

import Foundation

extension Array {
    public final class Parallel<Element> {

        internal init(array: [Element]){
            let count = array.count
            let threads = ProcessInfo.processInfo.activeProcessorCount
            let queueLabel = "Array.Parallel: count - \(count)"
            let queueLabelData = "element: \(Element.self), \(CFAbsoluteTimeGetCurrent())"
            self.array = array
            self.insertQueue = .init(label: "\(queueLabel), \(queueLabelData)")
            self.amountThreads = threads
            self.sliceData = (count / threads, count % threads)
        }

        internal var amountThreads: Int
        internal let insertQueue: DispatchQueue
        internal let array: [Element]
        internal let sliceData: (step: Int, remainder: Int)
    }
}

//MARK: Private Methods
extension Array.Parallel {
    internal func amountThreads(_ amount: Int?) -> Int {
        if let amount {
            return amount > 6 ? 6 : amount < 2 ? 2 : amount
        }
        return self.amountThreads
    }
    
    internal func parallelize(
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
