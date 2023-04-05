/*
 
 Project: Octopus
 File: Parallel.swift
 Created by: Egor Boyko
 Date: 02.04.2023
 
 Status: #In progress | #Not decorated
 
*/

import Foundation

public final class Parallel<StructureData: Collection, Element> where StructureData.Element == Element {
    internal init(structureData: StructureData){
        let count = structureData.count
        let threads = ProcessInfo.processInfo.activeProcessorCount
        let queueLabel = "Array.Parallel: count - \(count)"
        let queueLabelData = "element: \(Element.self), \(CFAbsoluteTimeGetCurrent())"
        self.structureData = structureData
        self.insertQueue = .init(label: "\(queueLabel), \(queueLabelData)")
        self.amountThreads = threads
        self.sliceData = (count / threads, count % threads)
    }
    internal var amountThreads: Int
    internal let insertQueue: DispatchQueue
    internal let structureData: StructureData
    internal let sliceData: (step: Int, remainder: Int)
}

