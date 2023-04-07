/*
 
 Project: Octopus
 File: TestTimer.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

import Foundation

final class TestTimer {
    private init(){
        let now = CFAbsoluteTimeGetCurrent()
        self.startTime = now
        self.endTime = now
    }
    
    private var startTime: CFAbsoluteTime
    private var endTime: CFAbsoluteTime
    private var duration: CFAbsoluteTime {
        endTime - startTime
    }

    func stop() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()
        return duration
    }
    
    func start() {
        let now = CFAbsoluteTimeGetCurrent()
        self.startTime = now
        self.endTime = now
    }
}

extension TestTimer {
    static func start() -> TestTimer {
        .init()
    }
}
