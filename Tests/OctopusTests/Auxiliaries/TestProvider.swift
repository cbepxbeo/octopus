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
        let end = random ? Int.random(in: 1...1000) : iterations
        for i in 0...end{
            temp.append(.init(int: i, string: "error", bool: false))
            for z in 0...end{
                temp.append(
                    .init(
                        int: z + (i * end),
                        string: "\((random ? Int.random(in: 1...1000) : z))",
                        bool: Bool.random()
                    )
                )
            }
        }
        return temp
    }
    
    func getDictionary(random: Bool = true, iterations: Int = 100) -> [FakeData: FakeData] {
        var temp: [FakeData: FakeData] = [:]
        let end = random ? Int.random(in: 1...1000) : iterations
        for i in 0...end{
            temp[.init(int: i)] = .init(int: i, string: "error", bool: false)
            for z in 0...end{
                let value = z + (i * end)
                temp[.init(int: value)] =
                    .init(
                        int: value,
                        string: "\((random ? Int.random(in: 1...1000) : z))",
                        bool: Bool.random()
                    )
            }
        }
        return temp
    }
    
    func filterTask(option: TestProviderOption) -> (FakeData) -> Bool{
        switch option {
        case .low:
            return { $0.bool && $0.int == 99999 }
        case .medium:
            return {
                for _ in 1...100 {}
                return $0.bool && $0.int == 99999
            }
        case .high:
            return {
                for _ in 1...500 {}
                return $0.bool && $0.int == 99999
            }
        case .custom(let end):
            return {
                for _ in 1...end {}
                return $0.bool && $0.int == 99999
            }
        }
    }
    
    func filterTask(option: TestProviderOption) -> ((key: FakeData, value: FakeData)) -> Bool{
        switch option {
        case .low:
            return { $0.key.bool && $0.key.int == 99999 }
        case .medium:
            return {
                for _ in 1...50 {}
                return $0.key.bool && $0.key.int == 99999
            }
        case .high:
            return {
                for _ in 1...500 {}
                return $0.key.bool && $0.key.int == 99999
            }
        case .custom(let end):
            return {
                for _ in 1...end {}
                return $0.key.bool && $0.key.int == 99999
            }
        }
    }
    
    
    func mapTask(option: TestProviderOption) -> (FakeData) -> String{
        switch option {
        case .low:
            return { $0.string + "\($0.int)" }
        case .medium:
            return {
                for _ in 1...100 {}
                return $0.string + "\($0.int)"
            }
        case .high:
            return {
                for _ in 1...500 {}
                return $0.string + "\($0.int)"
            }
        case .custom(let end):
            return {
                for _ in 1...end {}
                return $0.string + "\($0.int)"
            }
        }
    }
    
}


enum TestProviderOption {
    case low, high, medium, custom(Int)
}
