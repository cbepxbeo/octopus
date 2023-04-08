/*
 
 Project: Octopus
 File: Parallel.swift
 Created by: Egor Boyko
 Date: 02.04.2023
 
 Status: #In progress | #Not decorated
 
*/

import Foundation

internal var parallelThreads: [DispatchQoS.QoSClass: [Int: DispatchQueue]] = [
    .userInteractive : [
        1 : .init(label: "userInteractive\(1)", qos: .userInteractive, attributes: .concurrent),
        2 : .init(label: "userInteractive\(2)", qos: .userInteractive, attributes: .concurrent),
        3 : .init(label: "userInteractive\(3)", qos: .userInteractive, attributes: .concurrent),
        4 : .init(label: "userInteractive\(4)", qos: .userInteractive, attributes: .concurrent),
        5 : .init(label: "userInteractive\(5)", qos: .userInteractive, attributes: .concurrent),
        6 : .init(label: "userInteractive\(6)", qos: .userInteractive, attributes: .concurrent),
        7 : .init(label: "userInteractive\(7)", qos: .userInteractive, attributes: .concurrent),
        8 : .init(label: "userInteractive\(8)", qos: .userInteractive, attributes: .concurrent)
    ]
]

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

