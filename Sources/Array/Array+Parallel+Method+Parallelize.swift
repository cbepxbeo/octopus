/*
 
 Project: Octopus
 File: Array+Parallel+Method+Parallelize.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
 Status: #In progress | #Not decorated
 
*/
import Foundation

extension Array.Parallel {
    internal func parallelize(
        amountThreads: Int,
        group: DispatchGroup,
        priority: DispatchQoS.QoSClass,
        _ action: @escaping (_ iteration: Int, _ slice: ClosedRange<Int>) -> ()){
        for currentIteration in 1...amountThreads {
            let startIndex = self.sliceData.step * (currentIteration - 1)
            let endIndex = currentIteration == amountThreads ?
            ((self.sliceData.step * currentIteration) + self.sliceData.remainder - 1) :
            ((self.sliceData.step * currentIteration) - 1)
            group.enter()
            DispatchQueue.global(qos: priority).async {
                action(currentIteration, startIndex...endIndex)
            }
        }
    }
}
