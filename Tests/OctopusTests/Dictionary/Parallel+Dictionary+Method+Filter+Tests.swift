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
    var staticBigDictionary: Dictionary<FakeData, FakeData>!
    var staticVeryBigDictionary: Dictionary<FakeData, FakeData>!
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.staticDictionary = self.getDictionary(random: false, iterations: 100)
        self.staticBigDictionary = self.getDictionary(random: false, iterations: 50)
        self.staticVeryBigDictionary = self.getDictionary(random: false, iterations: 50)
    }
    override func tearDownWithError() throws {
        self.staticDictionary = nil
        self.staticBigDictionary = nil
        self.staticVeryBigDictionary = nil
        try super.tearDownWithError()
    }
    
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
        let timer = TestTimer.start()
        let _ = self.staticDictionary.filter(self.filterTask(option: .custom(optionValue)))
        let defaultFilterTime = timer.stop()
        logger.debug("testSpeed: defaultFilterTime - \(defaultFilterTime)")
        
        timer.start()
        let _ = self.staticDictionary.parallel().filter(self.filterTask(option: .custom(optionValue)))
        let parallelFilterTime = timer.stop()
        logger.debug("testSpeed: parallelFilterTime - \(parallelFilterTime)")
        XCTAssert(defaultFilterTime > parallelFilterTime)
    }
    
    func testSpeedBigDictionarySize() throws {
        let optionValue = 10
        let timer = TestTimer.start()
        let _ = self.staticBigDictionary.filter(self.filterTask(option: .custom(optionValue)))
        let defaultFilterTime = timer.stop()
        logger.debug("testSpeed: defaultFilterTime - \(defaultFilterTime)")
        
        timer.start()
        let _ = self.staticBigDictionary.parallel().filter(self.filterTask(option: .custom(optionValue)))
        let parallelFilterTime = timer.stop()
        logger.debug("testSpeed: parallelFilterTime - \(parallelFilterTime)")
        XCTAssert(defaultFilterTime > parallelFilterTime)
    }
    
    func testSpeedVeryBigDictionarySize() throws {
        let optionValue = 5
        let timer = TestTimer.start()
        let _ = self.staticBigDictionary.filter(self.filterTask(option: .custom(optionValue)))
        let defaultFilterTime = timer.stop()
        logger.debug("testSpeed: defaultFilterTime - \(defaultFilterTime)")
        
        timer.start()
        let _ = self.staticBigDictionary.parallel().filter(self.filterTask(option: .custom(optionValue)))
        let parallelFilterTime = timer.stop()
        logger.debug("testSpeed: parallelFilterTime - \(parallelFilterTime)")
        XCTAssert(defaultFilterTime > parallelFilterTime)
    }
    
    
    func testExample() throws {
        let arrayA: [Int] = .init(repeating: 10, count: 1000)
        let arrayB: [Int] = .init(repeating: 20, count: 1000)
        
        var dictionary: [Int: [Int]] = [:]
        for item in 0...10000 {
            dictionary[item] = item % 2 == 0 ? arrayA : arrayB
        }
        let timer = TestTimer.start()
        let _ = dictionary.filter{
            $0.value.reduce(0) { $0 + $1 } > 10000
        }
        let defaultFilterTime = timer.stop()
        logger.debug("testSpeed: defaultFilterTime - \(defaultFilterTime)")
        
        timer.start()
        let _ = dictionary.parallel().filter {
            $0.value.reduce(0) { $0 + $1 } > 10000
        }
        let parallelFilterTime = timer.stop()
        logger.debug("testSpeed: parallelFilterTime - \(parallelFilterTime)")
        XCTAssert(defaultFilterTime > parallelFilterTime)
    }
    
}
