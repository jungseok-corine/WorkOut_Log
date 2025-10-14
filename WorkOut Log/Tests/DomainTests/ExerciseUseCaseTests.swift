//
//  ExerciseUseCaseTests.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import XCTest
@testable import workout_log

final class ExerciseUseCaseTests: XCTestCase {
    var mockRepo: MockExerciseRepository!
    var upsertUseCase: UpsertExerciseUseCase!
    var searchUseCase: SearchExercisesUseCase!
    var recentUseCase: RecentExercisesUseCase!

    override func setUpWithError() throws {
        mockRepo = MockExerciseRepository()
        upsertUseCase = UpsertExerciseUseCase(repo: mockRepo)
        searchUseCase = SearchExercisesUseCase(repo: mockRepo)
        recentUseCase = RecentExercisesUseCase(repo: mockRepo)
    }

    func test_upsertExercise_createsNewExercise() async throws {
        // When
        let exercise = try await upsertUseCase(name: "Bench Press", category: .chest)

        // Then
        XCTAssertEqual(exercise.name, "Bench Press")
        XCTAssertEqual(exercise.category, .chest)
        XCTAssertFalse(exercise.id.isEmpty)
        XCTAssertEqual(mockRepo.upsertedExercises.count, 1)
    }

    func test_upsertExercise_trimsWhitespace() async throws {
        // When
        let exercise = try await upsertUseCase(name: "  Squat  ", category: .legs)

        // Then
        XCTAssertEqual(exercise.name, "Squat")
        XCTAssertEqual(exercise.category, .legs)
    }

    func test_searchExercises_returnsMatchingResults() async throws {
        // Given
        mockRepo.mockSearchResults = [
            Exercise(id: "1", name: "Bench Press", category: .chest),
            Exercise(id: "2", name: "Incline Bench", category: .chest),
            Exercise(id: "3", name: "Squat", category: .legs)
        ]

        // When
        let results = try await searchUseCase(query: "bench")

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.name.lowercased().contains("bench") })
    }

    func test_searchExercises_withCategoryFilter() async throws {
        // Given
        mockRepo.mockSearchResults = [
            Exercise(id: "1", name: "Bench Press", category: .chest),
            Exercise(id: "2", name: "Leg Press", category: .legs)
        ]

        // When
        let results = try await searchUseCase(query: "press", category: .chest)

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.category, .chest)
    }

    func test_recentExercises_returnsLimitedResults() async throws {
        // Given
        mockRepo.mockRecentResults = [
            Exercise(id: "1", name: "Exercise 1", category: .chest),
            Exercise(id: "2", name: "Exercise 2", category: .back),
            Exercise(id: "3", name: "Exercise 3", category: .legs)
        ]

        // When
        let results = try await recentUseCase(limit: 2)

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(mockRepo.lastRecentLimit, 2)
    }
}

// MARK: - Mock Repository

class MockExerciseRepository: ExerciseRepository {
    var upsertedExercises: [Exercise] = []
    var mockSearchResults: [Exercise] = []
    var mockRecentResults: [Exercise] = []
    var mockAllResults: [Exercise] = []
    var lastSearchQuery: String?
    var lastRecentLimit: Int?

    func upsert(_ exercise: Exercise) async throws {
        upsertedExercises.append(exercise)
    }

    func search(nameLike: String) async throws -> [Exercise] {
        lastSearchQuery = nameLike
        return mockSearchResults
    }

    func recent(limit: Int) async throws -> [Exercise] {
        lastRecentLimit = limit
        return Array(mockRecentResults.prefix(limit))
    }

    func fetchByCategory(_ category: ExerciseCategory) async throws -> [Exercise] {
        return mockAllResults.filter { $0.category == category }
    }

    func fetchAll() async throws -> [Exercise] {
        return mockAllResults
    }

    func fetch(by id: String) async throws -> Exercise? {
        return mockAllResults.first { $0.id == id }
    }
}