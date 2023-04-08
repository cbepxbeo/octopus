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

}
