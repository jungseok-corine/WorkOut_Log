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
    var deleteUseCase: DeleteExerciseUseCase!
    var searchUseCase: SearchExercisesUseCase!
    var recentUseCase: RecentExercisesUseCase!

    override func setUpWithError() throws {
        mockRepo = MockExerciseRepository()
        upsertUseCase = UpsertExerciseUseCase(repo: mockRepo)
        deleteUseCase = DeleteExerciseUseCase(repo: mockRepo)
        searchUseCase = SearchExercisesUseCase(repo: mockRepo)
        recentUseCase = RecentExercisesUseCase(repo: mockRepo)
    }

    func test_upsertExercise_createsNewExercise() async throws {
        // When
        let exercise = try await upsertUseCase(name: "Bench Press", main: .upperBody)

        // Then
        XCTAssertEqual(exercise.name, "Bench Press")
        XCTAssertEqual(exercise.main, .upperBody)
        XCTAssertFalse(exercise.id.isEmpty)
        XCTAssertEqual(mockRepo.upsertedExercises.count, 1)
    }

    func test_upsertExercise_trimsWhitespace() async throws {
        // When
        let exercise = try await upsertUseCase(name: "  Squat  ", main: .lowerBody)

        // Then
        XCTAssertEqual(exercise.name, "Squat")
        XCTAssertEqual(exercise.main, .lowerBody)
    }

    func test_deleteExercise_withoutSets_succeeds() async throws {
        // Given
        mockRepo.hasSets = false

        // When
        try await deleteUseCase(id: "1")

        // Then
        XCTAssertEqual(mockRepo.deletedExerciseIDs.count, 1)
        XCTAssertEqual(mockRepo.deletedExerciseIDs.first, "1")
    }

    func test_deleteExercise_withSets_throwsError() async throws {
        // Given
        mockRepo.hasSets = true

        // When/Then
        do {
            try await deleteUseCase(id: "1")
            XCTFail("Expected error to be thrown")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, 2)
            XCTAssertTrue(nsError.localizedDescription.contains("Cannot delete"))
        }
    }

    func test_searchExercises_returnsMatchingResults() async throws {
        // Given
        mockRepo.mockSearchResults = [
            Exercise(id: "1", name: "Bench Press", main: .upperBody),
            Exercise(id: "2", name: "Incline Bench", main: .upperBody),
            Exercise(id: "3", name: "Squat", main: .lowerBody)
        ]

        // When
        let results = try await searchUseCase(query: "bench", main: nil)

        // Then
        XCTAssertEqual(results.count, 3)
    }

    func test_searchExercises_withMainFilter() async throws {
        // Given
        mockRepo.mockSearchResults = [
            Exercise(id: "1", name: "Bench Press", main: .upperBody),
            Exercise(id: "2", name: "Leg Press", main: .lowerBody)
        ]

        // When
        let results = try await searchUseCase(query: "press", main: .upperBody)

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.main, .upperBody)
    }

    func test_recentExercises_returnsLimitedResults() async throws {
        // Given
        mockRepo.mockRecentResults = [
            Exercise(id: "1", name: "Exercise 1", main: .upperBody),
            Exercise(id: "2", name: "Exercise 2", main: .lowerBody),
            Exercise(id: "3", name: "Exercise 3", main: .cardio)
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
    var deletedExerciseIDs: [String] = []
    var mockSearchResults: [Exercise] = []
    var mockRecentResults: [Exercise] = []
    var mockAllResults: [Exercise] = []
    var lastSearchQuery: String?
    var lastRecentLimit: Int?
    var hasSets: Bool = false

    func upsert(_ exercise: Exercise) async throws {
        upsertedExercises.append(exercise)
    }

    func delete(id: String) async throws {
        if hasSets {
            throw NSError(
                domain: "ExerciseRepository",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Cannot delete exercise with existing sets"]
            )
        }
        deletedExerciseIDs.append(id)
    }

    func hasReferencingSets(exerciseID: String) async throws -> Bool {
        return hasSets
    }

    func search(nameLike: String) async throws -> [Exercise] {
        lastSearchQuery = nameLike
        return mockSearchResults
    }

    func recent(limit: Int) async throws -> [Exercise] {
        lastRecentLimit = limit
        return Array(mockRecentResults.prefix(limit))
    }

    func fetchByMain(_ main: ExerciseCategoryMain) async throws -> [Exercise] {
        return mockAllResults.filter { $0.main == main }
    }

    func fetchAll() async throws -> [Exercise] {
        return mockAllResults
    }

    func fetch(by id: String) async throws -> Exercise? {
        return mockAllResults.first { $0.id == id }
    }
}