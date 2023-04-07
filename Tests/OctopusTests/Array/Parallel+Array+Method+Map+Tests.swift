/*
 
 Project: Octopus
 File: Parallel+Array+Method+Filter+Tests.swift
 Created by: Egor Boyko
 Date: 05.04.2023
 
 
*/

import XCTest
@testable import Octopus

final class ParallelArrayMethodMapTests: XCTestCase, TestProvider {
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
    
    func testSpeed() throws {
        let timer = TestTimer.start()
        let _ = self.randomArray.map(self.mapTask(option: .low))
        let defaultFilterTime = timer.stop()
        
        timer.start()
        let _ = self.randomArray.parallel().map(self.mapTask(option: .low))
        let parallelFilterTime = timer.stop()
        XCTAssert(defaultFilterTime > parallelFilterTime)
    }
    
    func testPerfomance() throws {
        //M1, Simulator, 14 Pro Max, iOS 16.2, xcode 14.2
        self.customMeasure(ms: 1000){
            let _ = self.staticArray.parallel().map(self.mapTask(option: .low))
        }
    }
}
