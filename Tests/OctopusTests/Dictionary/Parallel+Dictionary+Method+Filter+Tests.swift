/*
 
 Project: Octopus
 File: Parallel+Dictionary+Method+Filter+Tests.swift
 Created by: Egor Boyko
 Date: 06.04.2023
 
 
*/

import XCTest
import OSLog
@testable import Octopus

fileprivate let logger: Logger = .init(
    subsystem: "octopus",
    category: "tests-parallel-dictionary-method-filter"
)

final class ParallelDictionaryMethodFilterTests: XCTestCase, TestProvider {
    var staticDictionary: Dictionary<Int, FakeData>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.staticDictionary = self.getDictionary(random: false, iterations: 1000)
    }
    override func tearDownWithError() throws {
        self.staticDictionary = nil
        try super.tearDownWithError()
    }
    
    func testMerge() {
        var dictoinary: [Int: FakeData] = [:]
        for item in 1...20 {
            dictoinary[item] = .init()
        }
        
        let first = dictoinary.parallel().filter { key in
            key > 10 && key < 15
        }
        print(first.count)
    }
    
    
    
    
    func testSpeed() throws {
        let timer = TestTimer.start()
        let _ = self.staticDictionary.filter { element in
            element.key % 2 == 0
        }
        let defaultFilterTime = timer.stop()
        logger.debug("testSpeed: defaultFilterTime - \(defaultFilterTime)")
        
        timer.start()
        let _ = self.staticDictionary.parallel().filter { key in
            key % 2 == 0
        }
        let parallelFilterTime = timer.stop()
        logger.debug("testSpeed: parallelFilterTime - \(parallelFilterTime)")
        XCTAssert(defaultFilterTime > parallelFilterTime)
    }
}
