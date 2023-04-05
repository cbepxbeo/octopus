/*
 
 Project: Octopus
 File: Array+Parallel+Method+Filter+Tests.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
 
*/

import XCTest
@testable import Octopus

final class ArrayParallelMethodFilterTests: XCTestCase, TestArrayProvider {
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
        let _ = self.randomArray.filter(self.filterDefaultTask)
        let defaultFilterTime = timer.stop()
        
        timer.start()
        let _ = self.randomArray.parallel().filter(self.filterDefaultTask)
        let parallelFilterTime = timer.stop()
        XCTAssert(defaultFilterTime > parallelFilterTime)
    }
    
    func testPerfomance() throws {
        //M1, Simulator, 14 Pro Max, iOS 16.2, xcode 14.2
        self.customMeasure(ms: 90){
            let _ = self.staticArray.parallel().filter(self.filterDefaultTask)
        }
    }
}
