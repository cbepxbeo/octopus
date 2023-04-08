/*
 
 Project: Octopus
 File: Parallel+Dictionary+Method+Map+Tests.swift
 Created by: Egor Boyko
 Date: 07.04.2023
 
*/

import XCTest
import OSLog
@testable import Octopus

fileprivate let logger: Logger = .init(
    subsystem: "octopus",
    category: "tests-parallel-dictionary-method-filter"
)

final class ParallelDictionaryMethodMapTests: XCTestCase, TestProvider {
    func testSpeed() throws {
        logger.debug("testSpeed: getting array")
        let dictionary = self.getDictionary(random: false, iterations: 100)
        let timer = TestTimer.start()
        let _ = dictionary.map(self.mapTask(option: .custom(3)))
        let defaultFilterTime = timer.stop()
        logger.debug("testSpeed: defaultMapTime - \(defaultFilterTime)")
        
        timer.start()
        let _ = dictionary.parallel().map(self.mapTask(option: .custom(3)))
        let parallelFilterTime = timer.stop()
        logger.debug("testSpeed: parallelMapTime - \(parallelFilterTime)")
        XCTAssert(defaultFilterTime > parallelFilterTime)
    }
}
