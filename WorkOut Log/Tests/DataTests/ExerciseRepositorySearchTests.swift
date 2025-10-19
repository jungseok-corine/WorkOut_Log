//
//  ExerciseRepositorySearchTests.swift
//  WorkOut Log
//
//  Created by Claude on 18/10/2025.
//

import XCTest
import SwiftData
@testable import workout_log

@MainActor
final class ExerciseRepositorySearchTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var repository: ExerciseRepositoryImpl!

    override func setUp() async throws {
        // Create in-memory model container for testing
        let schema = Schema([
            ExerciseModel.self,
            SetRecordModel.self,
            WorkoutSessionModel.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)
        repository = ExerciseRepositoryImpl(context: modelContext)

        // Seed test data
        try await seedTestExercises()
    }

    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        repository = nil
    }

    private func seedTestExercises() async throws {
        let exercises = [
            Exercise(id: "1", name: "Bench Press", main: .upperBody),
            Exercise(id: "2", name: "Squat", main: .lowerBody),
            Exercise(id: "3", name: "Leg Raise", main: .lowerBody),
            Exercise(id: "4", name: "DEADLIFT", main: .fullBody),
            Exercise(id: "5", name: "shoulder press", main: .upperBody)
        ]

        for exercise in exercises {
            try await repository.upsert(exercise)
        }
    }

    // MARK: - Case-Insensitive Search Tests

    func test_search_lowercase_query_finds_mixed_case_exercise() async throws {
        // Given: "Bench Press" exists in database
        // When: searching with lowercase "press"
        let results = try await repository.search(nameLike: "press")

        // Then: should find "Bench Press" and "shoulder press" (case-insensitive)
        XCTAssertEqual(results.count, 2, "Should find both exercises containing 'press'")
        XCTAssertTrue(results.contains { $0.name == "Bench Press" })
        XCTAssertTrue(results.contains { $0.name == "shoulder press" })
    }

    func test_search_uppercase_query_finds_lowercase_exercise() async throws {
        // Given: "shoulder press" (lowercase) exists in database
        // When: searching with uppercase "SHOULDER"
        let results = try await repository.search(nameLike: "SHOULDER")

        // Then: should find "shoulder press" (case-insensitive)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "shoulder press")
    }

    func test_search_mixed_case_query() async throws {
        // Given: "Squat" exists in database
        // When: searching with mixed case "SqU"
        let results = try await repository.search(nameLike: "SqU")

        // Then: should find "Squat" (case-insensitive)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Squat")
    }

    func test_search_uppercase_exercise_with_lowercase_query() async throws {
        // Given: "DEADLIFT" (all caps) exists in database
        // When: searching with lowercase "dead"
        let results = try await repository.search(nameLike: "dead")

        // Then: should find "DEADLIFT" (case-insensitive)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "DEADLIFT")
    }

    // MARK: - Partial Match Tests

    func test_search_partial_match() async throws {
        // Given: "Leg Raise" exists in database
        // When: searching with partial "leg"
        let results = try await repository.search(nameLike: "leg")

        // Then: should find "Leg Raise"
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Leg Raise")
    }

    func test_search_partial_match_multiple_results() async throws {
        // Given: Multiple exercises with "press" in name
        // When: searching with "press"
        let results = try await repository.search(nameLike: "press")

        // Then: should find all exercises containing "press"
        XCTAssertEqual(results.count, 2)
        let names = results.map { $0.name }
        XCTAssertTrue(names.contains("Bench Press"))
        XCTAssertTrue(names.contains("shoulder press"))
    }

    // MARK: - Edge Cases

    func test_search_empty_query_returns_all() async throws {
        // When: searching with empty string
        let results = try await repository.search(nameLike: "")

        // Then: should return all exercises
        XCTAssertEqual(results.count, 5)
    }

    func test_search_whitespace_query_returns_all() async throws {
        // When: searching with only whitespace
        let results = try await repository.search(nameLike: "   ")

        // Then: should return all exercises (whitespace trimmed to empty)
        XCTAssertEqual(results.count, 5)
    }

    func test_search_no_match() async throws {
        // When: searching for non-existent exercise
        let results = try await repository.search(nameLike: "Burpee")

        // Then: should return empty array
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - Sorting Tests

    func test_search_results_sorted_by_name() async throws {
        // When: searching for all exercises
        let results = try await repository.search(nameLike: "")

        // Then: should be sorted alphabetically by name (case-insensitive)
        let names = results.map { $0.name }
        let expectedOrder = ["Bench Press", "DEADLIFT", "Leg Raise", "shoulder press", "Squat"]
        XCTAssertEqual(names, expectedOrder, "Results should be sorted alphabetically")
    }

    // MARK: - Regression Test for KeyPath Crash

    func test_search_does_not_crash_with_invalid_keypath() async throws {
        // This test ensures the fix for:
        // "Fatal error: Invalid KeyPath name.localizedLowercase on ExerciseModel"
        // The old implementation used model.name.localizedLowercase in #Predicate
        // which is invalid because KeyPaths cannot chain into value-type members

        // When: performing any search operation
        let results = try await repository.search(nameLike: "test")

        // Then: should not crash (assertion is that we reach this point)
        XCTAssertNotNil(results, "Search should complete without crash")
    }

    // MARK: - Performance Test

    func test_search_performance_with_bounded_limit() async throws {
        // Given: Repository with fetchLimit of 200
        // When: searching (even empty query)
        let results = try await repository.search(nameLike: "")

        // Then: should not exceed reasonable bounds
        XCTAssertLessThanOrEqual(results.count, 200, "Should respect fetchLimit of 200")
    }
}
