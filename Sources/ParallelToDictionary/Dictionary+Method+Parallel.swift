//
//  File.swift
//  
//
//  Created by Егор Бойко on 06.04.2023.
//

import Foundation

extension Dictionary {
    public func parallel() -> Parallel<Dictionary, Element> {
        print(Element.self)
        return .init(structureData: self)
    }
}
