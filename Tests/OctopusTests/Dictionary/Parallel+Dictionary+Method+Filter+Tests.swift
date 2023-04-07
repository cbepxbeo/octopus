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
    func testMerge() {
        var dictoinary: [Int: FakeData] = [:]
        for item in 1...20 {
            dictoinary[item] = .init()
        }
        
        let result = dictoinary.parallel().filter { $0.key > 10 && $0.key < 15 }
        XCTAssert(result.count == 4)
    }
    
    func testSpeedDefaultDictionarySize() throws {
        let optionValue = 20
        logger.debug("testSpeedDefaultDictionarySize: getting array")
        let array = self.getDictionary(random: false, iterations: 100)
        let timer = TestTimer.start()
        let _ = array.filter(self.filterTask(option: .custom(optionValue)))
        let defaultFilterTime = timer.stop()
        logger.debug("testSpeedDefaultDictionarySize: defaultFilterTime - \(defaultFilterTime)")
        
        timer.start()
        let _ = array.parallel().filter(self.filterTask(option: .custom(optionValue)))
        let parallelFilterTime = timer.stop()
        logger.debug("testSpeedDefaultDictionarySize: parallelFilterTime - \(parallelFilterTime)")
        XCTAssert(defaultFilterTime > parallelFilterTime)
    }
    
    func testSpeedBigDictionarySize() throws {
        let optionValue = 10
        logger.debug("testSpeedBigDictionarySize: getting array")
        let array = self.getDictionary(random: false, iterations: 1000)
        let timer = TestTimer.start()
        let _ = array.filter(self.filterTask(option: .custom(optionValue)))
        let defaultFilterTime = timer.stop()
        logger.debug("testSpeedBigDictionarySize: defaultFilterTime - \(defaultFilterTime)")
        
        timer.start()
        let _ = array.parallel().filter(self.filterTask(option: .custom(optionValue)))
        let parallelFilterTime = timer.stop()
        logger.debug("testSpeedBigDictionarySize: parallelFilterTime - \(parallelFilterTime)")
        XCTAssert(defaultFilterTime > parallelFilterTime)
    }
    
    func testSpeedVeryBigDictionarySize() throws {
        let optionValue = 5
        logger.debug("testSpeedVeryBigDictionarySize: getting array")
        let array = self.getDictionary(random: false, iterations: 5000)
        let timer = TestTimer.start()
        let _ = array.filter(self.filterTask(option: .custom(optionValue)))
        let defaultFilterTime = timer.stop()
        logger.debug("testSpeedVeryBigDictionarySize: defaultFilterTime - \(defaultFilterTime)")
        
        timer.start()
        let _ = array.parallel().filter(self.filterTask(option: .custom(optionValue)))
        let parallelFilterTime = timer.stop()
        logger.debug("testSpeedVeryBigDictionarySize: parallelFilterTime - \(parallelFilterTime)")
        XCTAssert(defaultFilterTime > parallelFilterTime)
    }
}
