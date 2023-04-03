/*
 
 Project: Octopus
 File: Array+Parallel+Method+AmountThreads.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
 Status: #Completed | #Not decorated
 
*/

extension Array.Parallel {
    internal func amountThreads(_ amount: Int?) -> Int {
        if let amount {
            return amount > 6 ? 6 : amount < 2 ? 2 : amount
        }
        return self.amountThreads
    }
}
