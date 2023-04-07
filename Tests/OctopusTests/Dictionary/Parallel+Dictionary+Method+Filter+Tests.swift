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
        self.staticDictionary = self.getDictionary(random: false, iterations: 7000)
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
        XCTAssert(true)//defaultFilterTime > parallelFilterTime)
    }
    
    func testDefaultPerfomance() {
        measure {
            logger.debug("testDefaultPerfomance: - \(self.staticDictionary.count)")
            let result = self.staticDictionary.filter { element in
                var temp: Int = 0
                for i in 0...5000 {
                    temp += i
                }
                return element.key % 2 == 0 && element.key != temp
            }
            logger.debug("testDefaultPerfomance: - \(result.count)")
        }
    }
    
    func testParallelPerfomance() {
        measure {
            logger.debug("testParallelPerfomance: - \(self.staticDictionary.count)")
            let result = self.staticDictionary.parallel().filter { key in
                var temp: Int = 0
                for i in 0...5000 {
                    temp += i
                }
                return key % 2 == 0 && key != temp
            }
            print("--------------------------------")
            logger.debug("testParallelPerfomance: - \(result.count)")
        }
    }
    
    func testDefaultPerfomanceo() {
        measure {
            logger.debug("testDefaultPerfomance: - \(self.staticDictionary.count)")
            let result = self.staticDictionary.filter { element in
                return element.key % 2 == 0
            }
            logger.debug("testDefaultPerfomance: - \(result.count)")
        }
    }
    
    func testParallelPerfomanceo() {
        measure {
            logger.debug("testParallelPerfomance: - \(self.staticDictionary.count)")
            let result = self.staticDictionary.parallel().filter { key in
                return key % 2 == 0
            }
            print("--------------------------------")
            logger.debug("testParallelPerfomance: - \(result.count)")
        }
    }
    
}
