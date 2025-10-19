//
//  SanityTests.swift
//  WorkOut Log
//
//  Created by Claude on 18/10/2025.
//

import XCTest
@testable import workout_log

final class SanityTests: XCTestCase {
    func testSanity() {
        // This test verifies that XCTest resolves correctly
        // and that @testable import workout_log works
        XCTAssertTrue(true, "XCTest framework loaded successfully")
    }

    func testModuleImport() {
        // Verify we can access workout_log module types
        let exercise = Exercise(id: "test", name: "Test", main: .upperBody)
        XCTAssertEqual(exercise.id, "test")
        XCTAssertEqual(exercise.name, "Test")
        XCTAssertEqual(exercise.main, .upperBody)
    }
}
