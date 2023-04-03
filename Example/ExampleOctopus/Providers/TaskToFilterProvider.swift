/*
 
 File: TaskToFilterProvider.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

protocol TaskToFilterProvider {}

extension TaskToFilterProvider {
    func fakeTaskToFilter(_ value: Fake) -> Bool {
        var temp = 0
        for item in 0...500 {
            temp += item
        }
        return value.int == temp && value.string == "a"
    }
}
