/*
 
 Project: Octopus
 File: Parallel+Shared+Tests.swift
 Created by: Egor Boyko
 Date: 08.04.2023
 
 
*/

import XCTest
import OSLog
@testable import Octopus

fileprivate let logger: Logger = .init(
    subsystem: "octopus",
    category: "tests-parallel-shared"
)

final class ParallelSharedTests: XCTestCase, TestProvider {

    func testSpeedDictionaryWithArray() throws {
        let names: [String] = [
            "Adam",     "Abraham",
            "Bernard",  "Brian",
            "Caleb",    "Carl",
            "Daniel",   "Derek",
            "Eric",     "Ernest",
            "Felix",    "Frederick",
            "Gabriel",  "Gregory",
            "Harry",    "Henry",
            "Jack",     "Jacob",
            "Kurt",     "Kyle",
            "Lucas",    "Leonard",
            "Marcus",   "Martin",
            "Scott",    "Simon",
            "Travis",   "Tyler",
            "Wayne",    "Winston",
        ]
        
        let namesWithZ = names + ["Zachary"]
        let namesWithO = names + ["Oliver"]
        let namesWithZAndO = namesWithZ + ["Oliver"]
 
        var dictionary: [Int: [String]] = [:]
        
        for item in 1...10000 {
            if item % 3 == 0 {
                dictionary[item] = namesWithZ
            } else if item % 2 == 0 {
                dictionary[item] = namesWithO
            } else {
                dictionary[item] = namesWithZAndO
            }
        }
        
        let timer = TestTimer.start()
        
        let defaultResult = dictionary.filter { element in
            let uppercased = element.value.map { string in
                string.uppercased()
            }
            let namesWithZ = uppercased.filter { string in
                if let ch = string.first {
                    return ch == "Z"
                }
                return false
            }
            
            if namesWithZ.count == 0 {
                return false
            }
            let namesWithO = uppercased.filter { string in
                if let ch = string.first {
                    return ch == "O"
                }
                return false
            }
            return namesWithO.count != 0
        }
        
        let defaultFilterTime = timer.stop()
        logger.debug("defaultResult count: \(defaultResult.count)")
        logger.debug("testSpeedDictionaryWithArray: defaultFilterTime - \(defaultFilterTime)")
        
        timer.start()
        let parallelResult = dictionary.parallel().filter { element in
            let uppercased = element.value.map { string in
                string.uppercased()
            }
            let namesWithZ = uppercased.filter { string in
                if let ch = string.first {
                    return ch == "Z"
                }
                return false
            }
            
            if namesWithZ.count == 0 {
                return false
            }
            let namesWithO = uppercased.filter { string in
                if let ch = string.first {
                    return ch == "O"
                }
                return false
            }
            return namesWithO.count != 0
        }
        
        let parallelFilterTime = timer.stop()
        logger.debug("parallelResult count: \(parallelResult.count)")
        logger.debug("testSpeedDictionaryWithArray: parallelFilterTime - \(parallelFilterTime)")
        
        timer.start()
        let multiParallelResult = dictionary.parallel().filter { element in
            let uppercased = element.value.parallel().map { string in
                string.uppercased()
            }
            let namesWithZ = uppercased.parallel().filter { string in
                if let ch = string.first {
                    return ch == "Z"
                }
                return false
            }
            
            if namesWithZ.count == 0 {
                return false
            }
            let namesWithO = uppercased.parallel().filter { string in
                if let ch = string.first {
                    return ch == "O"
                }
                return false
            }
            return namesWithO.count != 0
        }
        let multiParallelFilterTime = timer.stop()
        logger.debug("multiParallelResult count: \(multiParallelResult.count)")
        logger.debug("testSpeedDictionaryWithArray: multiParallelFilterTime - \(multiParallelFilterTime)")
        
        
    }
}
