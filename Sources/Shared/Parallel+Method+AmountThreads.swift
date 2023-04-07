/*
 
 Project: Octopus
 File: Parallel+Method+AmountThreads.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
 Status: #Completed | #Not decorated
 
*/

import Foundation

extension Parallel {
    internal func amountThreads(_ amount: Int?) -> Int {
        if let amount {
            let max = ProcessInfo.processInfo.activeProcessorCount
            let min = 2
            return amount > max ? max : amount < min ? min : amount
        }
        return self.amountThreads
    }
}
