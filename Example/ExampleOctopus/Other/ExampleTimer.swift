/*
 
 File: ExampleTimer.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

import Foundation

final class ExampleTimer {
    private init(){
        let now = CFAbsoluteTimeGetCurrent()
        self.start = now
        self.end = now
    }
    
    private let start: CFAbsoluteTime
    private var end: CFAbsoluteTime
    private var duration: CFAbsoluteTime {
        end - start
    }

    func stop() -> CFAbsoluteTime {
        end = CFAbsoluteTimeGetCurrent()
        return duration
    }
}

extension ExampleTimer {
    static func start() -> ExampleTimer {
        .init()
    }
}
