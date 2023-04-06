/*
 
 Project: Octopus
 File: FakeData.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

struct FakeData {
    let int: Int
    let string: String
    let bool: Bool
    init(int: Int = 1, string: String = "", bool: Bool = false) {
        self.int = int
        self.string = string
        self.bool = bool
    }
}
