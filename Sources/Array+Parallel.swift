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
        
        private var amountThreads: Int
        private let insertQueue: MyDi
        private let array: [Element]
        private let sliceData: (step: Int, remainder: Int)
    }
}
