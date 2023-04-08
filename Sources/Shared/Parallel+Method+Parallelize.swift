/*
 
 Project: Octopus
 File: Parallel+Method+Parallelize.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
 Status: #In progress | #Not decorated
 
*/
import Foundation

extension Parallel {
    
    internal func parallelize(
        amountThreads: Int,
        group: DispatchGroup,
        priority: DispatchQoS.QoSClass,
        _ action: @escaping (_ iteration: Int, _ slice: ClosedRange<Int>) -> ()){
            self.parallelize(
                amountThreads: amountThreads,
                group: group,
                priority: priority,
                { action($0, $1...$2) }
            )
    }
    
    internal func parallelize(
        amountThreads: Int,
        group: DispatchGroup,
        priority: DispatchQoS.QoSClass,
        _ action: @escaping (_ iteration: Int, _ start: Int, _ end: Int) -> ()){
            
        for currentIteration in 1...amountThreads {
            let startIndex = self.sliceData.step * (currentIteration - 1)
            let endIndex = currentIteration == amountThreads ?
            ((self.sliceData.step * currentIteration) + self.sliceData.remainder - 1) :
            ((self.sliceData.step * currentIteration) - 1)
            if startIndex >= endIndex {
                break
            }
            
            let queue: DispatchQueue
            if let priority = parallelThreads[priority], let dispatchQueue = priority[currentIteration] {
                queue = dispatchQueue
            } else {
                queue = .init(label: "\(priority)-\(currentIteration)", attributes: .concurrent)
                DispatchQueue.main.async {
                    parallelThreads[priority] = [currentIteration: queue]
                }
            }

            group.enter()
            queue.async {
                action(currentIteration, startIndex, endIndex)
            }
        }
    }
}
