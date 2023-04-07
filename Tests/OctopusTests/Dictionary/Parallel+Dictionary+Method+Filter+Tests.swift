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
    
    
    func testExample() throws {
        let arrayA: [Int] = .init(repeating: 10, count: 100)
        let arrayB: [Int] = .init(repeating: 20, count: 100)
        
        var dictionary: [Int: [Int]] = [:]
        for item in 0...1000 {
            dictionary[item] = item % 2 == 0 ? arrayA : arrayB
        }
        let timer = TestTimer.start()
        let _ = dictionary.filter{
            $0.value.reduce(0) { $0 + $1 } > 1000
        }
        let defaultFilterTime = timer.stop()
        logger.debug("testSpeed: defaultFilterTime - \(defaultFilterTime)")
        
        timer.start()
        let _ = dictionary.parallel().filter {
            $0.value.reduce(0) { $0 + $1 } > 1000
        }
        let parallelFilterTime = timer.stop()
        logger.debug("testSpeed: parallelFilterTime - \(parallelFilterTime)")
        XCTAssert(defaultFilterTime > parallelFilterTime)
    }
    
}
