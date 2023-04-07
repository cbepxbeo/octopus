/*
 
 Project: Octopus
 File: Dictionary+Method+Parallel.swift
 Created by: Egor Boyko
 Date: 06.04.2023
 
 Status: #In progress | #Not decorated
 
*/

import Foundation

extension Dictionary {
    public func parallel() -> Parallel<Dictionary, Element> {
        return .init(structureData: self)
    }
}
