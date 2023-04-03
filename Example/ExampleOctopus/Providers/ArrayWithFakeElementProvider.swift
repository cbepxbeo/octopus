/*
 
 File: ArrayWithFakeElementProvider.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

protocol ArrayWithFakeElementProvider {}

extension ArrayWithFakeElementProvider {
    func getArrayWithFakeElement() -> [Fake] {
        var temp: [Fake] = []
        for i in 0...1000 {
            temp.append(.init(string: "error", int: i))
            for z in 0...100{
                temp.append(.init(string: (i % 2 == 0) ? "a" : "b", int: z))
            }
        }
        return temp
    }
}
