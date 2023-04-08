/*
 
 Project: Octopus
 File: Parallel+Method+AmountThreads+Tests.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
 
*/

import XCTest
@testable import Octopus

final class ParallelMethodAmountThreadsTests: XCTestCase, TestProvider {
    var parallel: Parallel<Array<FakeData>, FakeData>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.parallel = self.getArray().parallel()
    }

    override func tearDownWithError() throws {
        self.parallel = nil
        try super.tearDownWithError()
    }
    
    func testMethod() throws {
        var temp: [Int] = [ Int.min, Int.max ]
        for _ in 0...100 {
            temp.append(Int.random(in: Int.min...Int.max))
        }
        for item in temp {
            let testable = self.parallel.amountThreads(item)
            let minСondition = testable > 1
            let maxСondition = testable <= ProcessInfo.processInfo.activeProcessorCount
            XCTAssert(minСondition && maxСondition)
        }
    }
}
