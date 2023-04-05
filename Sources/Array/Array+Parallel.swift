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
