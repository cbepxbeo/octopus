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

}

//MARK: Private Methods
extension Array.Parallel {
    private func amountThreads(_ amount: Int?) -> Int {
        if let amount {
            return amount > 6 ? 6 : amount < 2 ? 2 : amount
        }
        return self.amountThreads
    }
}
