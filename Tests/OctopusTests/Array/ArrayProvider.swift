/*
 
 Project: Octopus
 File: Array+Parallel+Method+AmountThreads+Tests.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
 
*/

import Foundation


protocol TestArrayProvider{}

extension TestArrayProvider {
    
    func getArray(random: Bool = true) -> [FakeData] {
        var temp: [FakeData] = []
        for i in 0...(random ? Int.random(in: 1...1000) : 10){
            temp.append(.init(int: i, string: "error", bool: false))
            for z in 0...(random ? Int.random(in: 1...1000) : 10){
                temp.append(
                    .init(
                        int: z,
                        string: "\(Int.random(in: 1...1000))",
                        bool: Bool.random()
                    )
                )
            }
        }
        return temp
    }
}
