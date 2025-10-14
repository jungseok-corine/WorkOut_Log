//
//  ComputePRUseCaseTests.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import XCTest
@testable import workout_log

final class ComputePRUseCaseTests: XCTestCase {
    var mockRepo: MockSessionRepository!
    var useCase: ComputePRUseCase!

    override func setUpWithError() throws {
        mockRepo = MockSessionRepository()
        useCase = ComputePRUseCase(sessionRepo: mockRepo)
    }

    func test_computePR_findsMaxWeight() async throws {
        // Given
        let session1 = WorkoutSession(id: "s1", date: Date(), note: nil)
        let session2 = WorkoutSession(id: "s2", date: Date(), note: nil)

        mockRepo.mockSessions = [session1, session2]
        mockRepo.mockSets = [
            "s1": [
                SetRecord(id: "set1", sessionID: "s1", exerciseID: "bench", weight: 80, reps: 10, order: 0),
                SetRecord(id: "set2", sessionID: "s1", exerciseID: "bench", weight: 85, reps: 8, order: 1)
            ],
            "s2": [
                SetRecord(id: "set3", sessionID: "s2", exerciseID: "bench", weight: 90, reps: 5, order: 0) // PR
            ]
        ]

        // When
        let pr = try await useCase(exerciseID: "bench")

        // Then
        XCTAssertNotNil(pr)
        XCTAssertEqual(pr?.exerciseID, "bench")
        XCTAssertEqual(pr?.maxWeight, 90)

        // Test Epley formula: 90 * (1 + 5/30) = 90 * 1.1667 = 105
        let expectedOneRM = 90 * (1 + 5.0 / 30.0)
        XCTAssertEqual(pr?.estimatedOneRM, expectedOneRM, accuracy: 0.01)
    }

    func test_computePR_returnsNilForUnknownExercise() async throws {
        // Given
        mockRepo.mockSessions = []
        mockRepo.mockSets = [:]

        // When
        let pr = try await useCase(exerciseID: "unknown")

        // Then
        XCTAssertNil(pr)
    }

    func test_isNewPR_returnsTrue_forFirstTime() async throws {
        // Given
        mockRepo.mockSessions = []
        mockRepo.mockSets = [:]

        // When
        let isNewPR = try await useCase.isNewPR(exerciseID: "bench", weight: 80, reps: 10)

        // Then
        XCTAssertTrue(isNewPR)
    }

    func test_isNewPR_returnsTrue_forHigherWeight() async throws {
        // Given
        let session = WorkoutSession(id: "s1", date: Date(), note: nil)
        mockRepo.mockSessions = [session]
        mockRepo.mockSets = [
            "s1": [SetRecord(id: "set1", sessionID: "s1", exerciseID: "bench", weight: 80, reps: 10, order: 0)]
        ]

        // When
        let isNewPR = try await useCase.isNewPR(exerciseID: "bench", weight: 85, reps: 10)

        // Then
        XCTAssertTrue(isNewPR)
    }

    func test_isNewPR_returnsTrue_forHigherEstimatedOneRM() async throws {
        // Given
        let session = WorkoutSession(id: "s1", date: Date(), note: nil)
        mockRepo.mockSessions = [session]
        mockRepo.mockSets = [
            "s1": [SetRecord(id: "set1", sessionID: "s1", exerciseID: "bench", weight: 100, reps: 1, order: 0)] // 1RM = 100
        ]

        // When - lower weight but more reps should give higher estimated 1RM
        // 95 * (1 + 3/30) = 95 * 1.1 = 104.5 > 100
        let isNewPR = try await useCase.isNewPR(exerciseID: "bench", weight: 95, reps: 3)

        // Then
        XCTAssertTrue(isNewPR)
    }

    func test_isNewPR_returnsFalse_forLowerPerformance() async throws {
        // Given
        let session = WorkoutSession(id: "s1", date: Date(), note: nil)
        mockRepo.mockSessions = [session]
        mockRepo.mockSets = [
            "s1": [SetRecord(id: "set1", sessionID: "s1", exerciseID: "bench", weight: 100, reps: 5, order: 0)]
        ]

        // When
        let isNewPR = try await useCase.isNewPR(exerciseID: "bench", weight: 90, reps: 4)

        // Then
        XCTAssertFalse(isNewPR)
    }

    func test_epleyFormula_accuracy() {
        // Test known values from Epley formula
        // 1RM = weight * (1 + reps/30)

        let testCases: [(weight: Double, reps: Int, expected1RM: Double)] = [
            (100, 1, 100.0),    // 100 * (1 + 1/30) = 103.33
            (90, 5, 105.0),     // 90 * (1 + 5/30) = 105.0
            (80, 10, 106.67),   // 80 * (1 + 10/30) = 106.67
            (70, 15, 105.0)     // 70 * (1 + 15/30) = 105.0
        ]

        for testCase in testCases {
            let calculated = testCase.weight * (1 + Double(testCase.reps) / 30.0)
            XCTAssertEqual(calculated, testCase.expected1RM, accuracy: 0.01,
                         "Failed for weight: \(testCase.weight), reps: \(testCase.reps)")
        }
    }
}