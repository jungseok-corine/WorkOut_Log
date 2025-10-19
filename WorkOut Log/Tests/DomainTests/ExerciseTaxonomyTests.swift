//
//  ExerciseTaxonomyTests.swift
//  WorkOut Log
//
//  Created by Claude on 15/10/2025.
//

import XCTest
@testable import workout_log

final class ExerciseTaxonomyTests: XCTestCase {
    func test_upperBody_exercise_creation() {
        let exercise = Exercise(id: "1", name: "Bench Press", main: .upperBody)
        XCTAssertEqual(exercise.id, "1")
        XCTAssertEqual(exercise.name, "Bench Press")
        XCTAssertEqual(exercise.main, .upperBody)
    }

    func test_all_main_categories() {
        let lowerExercise = Exercise(id: "1", name: "Squat", main: .lowerBody)
        XCTAssertEqual(lowerExercise.main, .lowerBody)

        let cardioExercise = Exercise(id: "2", name: "Running", main: .cardio)
        XCTAssertEqual(cardioExercise.main, .cardio)

        let fullBodyExercise = Exercise(id: "3", name: "Burpee", main: .fullBody)
        XCTAssertEqual(fullBodyExercise.main, .fullBody)

        let upperExercise = Exercise(id: "4", name: "Pull Up", main: .upperBody)
        XCTAssertEqual(upperExercise.main, .upperBody)
    }

    func test_upsert_creates_exercise() async throws {
        let repo = InMemoryExerciseRepository()
        let useCase = UpsertExerciseUseCase(repo: repo)

        // Test: upperBody exercise
        let upperExercise = try await useCase(name: "Bench Press", main: .upperBody)
        XCTAssertEqual(upperExercise.name, "Bench Press")
        XCTAssertEqual(upperExercise.main, .upperBody)

        // Test: lowerBody exercise
        let lowerExercise = try await useCase(name: "Squat", main: .lowerBody)
        XCTAssertEqual(lowerExercise.main, .lowerBody)
        XCTAssertEqual(lowerExercise.name, "Squat")
    }

    func test_search_filters_by_main_category() async throws {
        let repo = InMemoryExerciseRepository()
        let upsertUC = UpsertExerciseUseCase(repo: repo)
        let searchUC = SearchExercisesUseCase(repo: repo)

        // Create exercises
        _ = try await upsertUC(name: "Bench Press", main: .upperBody)
        _ = try await upsertUC(name: "Squat", main: .lowerBody)
        _ = try await upsertUC(name: "Deadlift", main: .lowerBody)

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
        exercises[exercise.id] = exercise
    }

    func search(nameLike: String) async throws -> [Exercise] {
        if nameLike.isEmpty {
            return Array(exercises.values)
        }
        return exercises.values.filter { $0.name.localizedStandardContains(nameLike) }
    }

    func recent(limit: Int) async throws -> [Exercise] {
        return Array(exercises.values.prefix(limit))
    }

    func fetchByMain(_ main: ExerciseCategoryMain) async throws -> [Exercise] {
        return exercises.values.filter { $0.main == main }
    }

    func fetchAll() async throws -> [Exercise] {
        return Array(exercises.values)
    }

    func fetch(by id: String) async throws -> Exercise? {
        return exercises[id]
    }

    func hasReferencingSets(exerciseID: String) async throws -> Bool {
        // For in-memory testing, always return false (no sets tracking)
        return false
    }
}
