/*
 
 Project: Octopus
 File: Array+Method+Parallel.swift
 Created by: Egor Boyko
 Date: 02.04.2023
 
 Status: #In progress | #Not decorated
 
*/

extension Array {
    public func parallel() -> Parallel<Array<Element>, Element> {
        .init(structureData: self)
    }
}
