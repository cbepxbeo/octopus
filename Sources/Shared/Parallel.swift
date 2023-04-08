/*
 
 Project: Octopus
 File: Parallel.swift
 Created by: Egor Boyko
 Date: 02.04.2023
 
 Status: #In progress | #Not decorated
 
*/

import Foundation

///Use Collection and related methods (parallel) to create Parallel instances.
public final class Parallel<StructureData: Collection, Element> where StructureData.Element == Element {
    internal init(structureData: StructureData){
        let count = structureData.count
        let threads = ProcessInfo.processInfo.activeProcessorCount
        let queueLabel = "Parallel: count - \(count)"
        let queueLabelData = "structure data: \(StructureData.self), element: \(Element.self)"
        let queueLabelRandom = "\(CFAbsoluteTimeGetCurrent())"
        self.structureData = structureData
        self.insertQueue = .init(label: "\(queueLabel), \(queueLabelData), \(queueLabelRandom)")
        self.amountThreads = threads
        self.sliceData = (count / threads, count % threads)
    }
    internal var amountThreads: Int
    internal let insertQueue: DispatchQueue
    internal let structureData: StructureData
    internal let sliceData: (step: Int, remainder: Int)
}

