/*
 
 Project: Octopus
 File: Parallel+Array+Method+Filter+Tests.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
 
*/

import XCTest
import OSLog
@testable import Octopus

fileprivate let logger: Logger = .init(
    subsystem: "octopus",
    category: "tests-parallel-array-method-filter"
)

final class ParallelArrayMethodFilterTests: XCTestCase, TestProvider {
    var randomArray: Array<FakeData>!
    var staticArray: Array<FakeData>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.randomArray = self.getArray()
        self.staticArray = self.getArray(random: false, iterations: 1000)
    }
    override func tearDownWithError() throws {
        self.randomArray = nil
        self.staticArray = nil
        try super.tearDownWithError()
    }
    
    func testMinArray() throws {
        let array = [FakeData()]
        let result = array.parallel().filter{ _ in true }
        XCTAssert(result.count == 1)
    }
    
    func testActiveProcessorCount() throws {
        let activeProcessorCount = ProcessInfo.processInfo.activeProcessorCount
        var array = Array(repeating: FakeData(), count: activeProcessorCount)
        logger.debug("testActiveProcessorCount: array count - \(array.count)")
        var result = array.parallel().filter{ _ in true }
        logger.debug("testActiveProcessorCount: result count - \(result.count)")
        XCTAssert(result.count == activeProcessorCount)
        array.append(.init())
        logger.debug("testActiveProcessorCount: array count - \(array.count)")
        result = array.parallel().filter{ _ in true }
        logger.debug("testActiveProcessorCount: result count - \(result.count)")
        XCTAssert(result.count == (activeProcessorCount + 1))
    }
    
    
    func testSpeed() throws {
        let timer = TestTimer.start()
        let _ = self.randomArray.filter(self.filterDefaultTask)
        let defaultFilterTime = timer.stop()
        logger.debug("testSpeed: defaultFilterTime - \(defaultFilterTime)")
        
        timer.start()
        let _ = self.randomArray.parallel().filter(self.filterDefaultTask)
        let parallelFilterTime = timer.stop()
        logger.debug("testSpeed: parallelFilterTime - \(parallelFilterTime)")
        XCTAssert(defaultFilterTime > parallelFilterTime)
    }
    
    func testPerfomance() throws {
        //M1, Simulator, 14 Pro Max, iOS 16.2, xcode 14.2
        self.customMeasure(ms: 90){
            let _ = self.staticArray.parallel().filter(self.filterDefaultTask)
        }
    }
}
