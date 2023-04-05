/*
 
 Project: Octopus
 File: Extension.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

import Foundation
import XCTest

extension XCTestCase{
    /// Executes the block and return the execution time in millis
    public func timeBlock(closure: ()->()) -> Int {
        var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        let begin = mach_absolute_time()

        closure()

        let diff = Double(mach_absolute_time() - begin) * Double(info.numer) / Double(1_000_000 * info.denom)
        return Int(diff)
    }
    
    public func customMeasure(ms: Int, closure: ()->()){
        for _ in 0..<10 {
            XCTAssertTrue(ms > self.timeBlock { closure() })
        }
    }
}
