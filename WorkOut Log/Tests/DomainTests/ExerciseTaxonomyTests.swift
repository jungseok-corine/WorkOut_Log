//
//  ExerciseTaxonomyTests.swift
//  WorkOut Log
//
//  Created by Claude on 15/10/2025.
//

import XCTest
@testable import workout_log

final class ExerciseTaxonomyTests: XCTestCase {
    func test_upperBody_requires_upper_subcategory() {
        let validExercise = Exercise(id: "1", name: "Bench Press", main: .upperBody, upper: .chest)
        XCTAssertTrue(validExercise.isValid)

        let invalidExercise = Exercise(id: "2", name: "Invalid", main: .upperBody, upper: nil)
        XCTAssertFalse(invalidExercise.isValid)
    }

    func test_non_upperBody_must_not_have_upper() {
        let validLower = Exercise(id: "1", name: "Squat", main: .lowerBody, upper: nil)
        XCTAssertTrue(validLower.isValid)

        let validCardio = Exercise(id: "2", name: "Running", main: .cardio, upper: nil)
        XCTAssertTrue(validCardio.isValid)

        let validFull = Exercise(id: "3", name: "Burpee", main: .fullBody, upper: nil)
        XCTAssertTrue(validFull.isValid)

        let invalidLower = Exercise(id: "4", name: "Invalid", main: .lowerBody, upper: .chest)
        XCTAssertFalse(invalidLower.isValid)
    }

    func test_upsert_validates_taxonomy() async throws {
        let repo = InMemoryExerciseRepository()
        let useCase = UpsertExerciseUseCase(repo: repo)

        // Valid: upperBody with upper subcategory
        let validExercise = try await useCase(name: "Bench Press", main: .upperBody, upper: .chest)
        XCTAssertEqual(validExercise.name, "Bench Press")
        XCTAssertEqual(validExercise.main, .upperBody)
        XCTAssertEqual(validExercise.upper, .chest)

        // Valid: lowerBody without upper
        let lowerExercise = try await useCase(name: "Squat", main: .lowerBody, upper: nil)
        XCTAssertEqual(lowerExercise.main, .lowerBody)
        XCTAssertNil(lowerExercise.upper)
    }

    func test_search_filters_by_main_category() async throws {
        let repo = InMemoryExerciseRepository()
        let upsertUC = UpsertExerciseUseCase(repo: repo)
        let searchUC = SearchExercisesUseCase(repo: repo)

        // Create exercises
        _ = try await upsertUC(name: "Bench Press", main: .upperBody, upper: .chest)
        _ = try await upsertUC(name: "Squat", main: .lowerBody, upper: nil)
        _ = try await upsertUC(name: "Deadlift", main: .lowerBody, upper: nil)

        // Search by main category
        let upperResults = try await searchUC(query: "", main: .upperBody)
        XCTAssertEqual(upperResults.count, 1)
        XCTAssertEqual(upperResults.first?.name, "Bench Press")

        let lowerResults = try await searchUC(query: "", main: .lowerBody)
        XCTAssertEqual(lowerResults.count, 2)
    }
}

// In-memory repository for testing
final class InMemoryExerciseRepository: ExerciseRepository {
    var exercises: [String: Exercise] = [:]

    func upsert(_ exercise: Exercise) async throws {
        guard exercise.isValid else {
            throw NSError(domain: "ExerciseRepository", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "upperBody requires upper subcategory"])
        }
        exercises[exercise.id] = exercise
    }

    func search(nameLike: String) async throws -> [Exercise] {
        if nameLike.isEmpty {
            return Array(exercises.values)
        }
        return exercises.values.filter { $0.name.localizedLowercase.contains(nameLike.lowercased()) }
    }

    func recent(limit: Int) async throws -> [Exercise] {
        return Array(exercises.values.prefix(limit))
    }

    func fetchByMain(_ main: ExerciseCategoryMain) async throws -> [Exercise] {
        return exercises.values.filter { $0.main == main }
    }

    func fetchByUpper(_ upper: ExerciseCategoryUpper) async throws -> [Exercise] {
        return exercises.values.filter { $0.upper == upper }
    }

    func fetchAll() async throws -> [Exercise] {
        return Array(exercises.values)
    }

    func fetch(by id: String) async throws -> Exercise? {
        return exercises[id]
    }
}
