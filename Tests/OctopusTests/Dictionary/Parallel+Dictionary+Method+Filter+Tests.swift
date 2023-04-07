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
    var staticDictionary: Dictionary<FakeData, FakeData>!
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.staticDictionary = self.getDictionary(random: false, iterations: 10)
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
        
        let result = dictoinary.parallel().filter { $0 > 10 && $0 < 15 }
        XCTAssert(result.count == 4)
    }
    
    
    func testSpeed() throws {
        let timer = TestTimer.start()
        let _ = self.staticDictionary.filter(self.filterTask(option: .medium))
        let defaultFilterTime = timer.stop()
        logger.debug("testSpeed: defaultFilterTime - \(defaultFilterTime)")
        
        timer.start()
        let _ = self.staticDictionary.parallel().filter(self.filterTask(option: .medium))
        let parallelFilterTime = timer.stop()
        logger.debug("testSpeed: parallelFilterTime - \(parallelFilterTime)")
        XCTAssert(defaultFilterTime > parallelFilterTime)
    }
    
}
