/*
 
 File: TaskToMapProvider.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

protocol TaskToMapProvider {}

extension TaskToMapProvider {
    func fakeTask(_ value: Fake) -> String {
        var temp = 0
        for item in 0...500 {
            temp += item
        }
        return "value:\(temp)"
    }
}
