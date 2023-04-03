import XCTest
@testable import Octopus

final class OctopusTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ParallelSequence().text, "Hello, World!")
    }
}
