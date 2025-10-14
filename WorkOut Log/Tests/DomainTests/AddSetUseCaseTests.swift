//
//  AddSetUseCaseTests.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import XCTest
@testable import workout_log

final class AddSetUseCaseTests: XCTestCase {
    var repo: InMemorySessionRepository!
    var useCase: AddSetUseCase!
    var sessionID: String!

    override func setUpWithError() throws {
        repo = InMemorySessionRepository()
        useCase = AddSetUseCase(repo: repo)
        sessionID = UUID().uuidString

        // Create a session first
        let session = WorkoutSession(id: sessionID, date: Date(), note: "Test session")
        Task {
            try await repo.create(session: session)
        }
    }

    func test_addSet_createsSetWithCorrectData() async throws {
        // Given
        let exerciseID = "bench-press"
        let weight = 80.0
        let reps = 10
        let order = 0

        // When
        let addedSet = try await useCase(sessionID: sessionID, exerciseID: exerciseID, weight: weight, reps: reps, order: order)

        // Then
        XCTAssertEqual(addedSet.sessionID, sessionID)
        XCTAssertEqual(addedSet.exerciseID, exerciseID)
        XCTAssertEqual(addedSet.weight, weight)
        XCTAssertEqual(addedSet.reps, reps)
        XCTAssertEqual(addedSet.order, order)
        XCTAssertEqual(addedSet.volume, weight * Double(reps))
        XCTAssertFalse(addedSet.id.isEmpty)
    }

    func test_addSet_persistsInRepository() async throws {
        // Given
        let exerciseID = "squat"
        let weight = 100.0
        let reps = 8
        let order = 1

        // When
        let addedSet = try await useCase(sessionID: sessionID, exerciseID: exerciseID, weight: weight, reps: reps, order: order)

        // Then
        let fetchedSets = try await repo.fetchSets(sessionID: sessionID)
        XCTAssertEqual(fetchedSets.count, 1)

        let fetchedSet = fetchedSets.first!
        XCTAssertEqual(fetchedSet.id, addedSet.id)
        XCTAssertEqual(fetchedSet.weight, weight)
        XCTAssertEqual(fetchedSet.reps, reps)
    }

    func test_addMultipleSets_maintainsCorrectOrder() async throws {
        // Given & When
        let set1 = try await useCase(sessionID: sessionID, exerciseID: "bench", weight: 60.0, reps: 12, order: 0)
        let set2 = try await useCase(sessionID: sessionID, exerciseID: "bench", weight: 65.0, reps: 10, order: 1)
        let set3 = try await useCase(sessionID: sessionID, exerciseID: "bench", weight: 70.0, reps: 8, order: 2)

        // Then
        let fetchedSets = try await repo.fetchSets(sessionID: sessionID)
        XCTAssertEqual(fetchedSets.count, 3)

        // Sets should be ordered by order property
        XCTAssertEqual(fetchedSets[0].order, 0)
        XCTAssertEqual(fetchedSets[1].order, 1)
        XCTAssertEqual(fetchedSets[2].order, 2)

        XCTAssertEqual(fetchedSets[0].weight, 60.0)
        XCTAssertEqual(fetchedSets[1].weight, 65.0)
        XCTAssertEqual(fetchedSets[2].weight, 70.0)
    }

    func test_addSet_calculatesVolumeCorrectly() async throws {
        // Given
        let weight = 82.5
        let reps = 6

        // When
        let addedSet = try await useCase(sessionID: sessionID, exerciseID: "deadlift", weight: weight, reps: reps, order: 0)

        // Then
        let expectedVolume = weight * Double(reps)
        XCTAssertEqual(addedSet.volume, expectedVolume, accuracy: 0.01)
    }
}