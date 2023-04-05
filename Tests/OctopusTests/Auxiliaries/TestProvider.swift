/*
 
 Project: Octopus
 File: TestProvider.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
 
*/

import Foundation


protocol TestProvider{}

extension TestProvider {
    
    func getArray(random: Bool = true, iterations: Int = 100) -> [FakeData] {
        var temp: [FakeData] = []
        for i in 0...(random ? Int.random(in: 1...1000) : iterations){
            temp.append(.init(int: i, string: "error", bool: false))
            for z in 0...(random ? Int.random(in: 1...1000) : iterations){
                temp.append(
                    .init(
                        int: z,
                        string: "\((random ? Int.random(in: 1...1000) : z))",
                        bool: Bool.random()
                    )
                )
            }
        }
        return temp
    }
    
    func filterDefaultTask(_ value: FakeData) -> Bool{
        value.bool && value.int == 99999
    }
    
    func mapDefaultTask(_ value: FakeData) -> String{
        value.string + "\(value.int)"
    }
    
}
