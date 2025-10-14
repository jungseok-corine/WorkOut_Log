//
//  SessionListVolumeTests.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import XCTest
@testable import workout_log

@MainActor
final class SessionListVolumeTests: XCTestCase {
    var repo: InMemorySessionRepository!
    var container: AppContainer!
    var viewModel: SessionListViewModel!

    override func setUpWithError() throws {
        repo = InMemorySessionRepository()

        // We'll need to create a mock container since AppContainer uses SwiftData
        // For now, let's test the repository logic directly
    }

    func test_sessionVolumeCalculation_reflectsAddedSets() async throws {
        // Given
        let sessionID = UUID().uuidString
        let session = WorkoutSession(id: sessionID, date: Date(), note: "Test session")
        try await repo.create(session: session)

        // When - Add sets
        let set1 = SetRecord(id: UUID().uuidString, sessionID: sessionID, exerciseID: "bench", weight: 80.0, reps: 10, order: 0)
        let set2 = SetRecord(id: UUID().uuidString, sessionID: sessionID, exerciseID: "bench", weight: 85.0, reps: 8, order: 1)

        try await repo.add(set: set1)
        try await repo.add(set: set2)

        // Then - Calculate total volume
        let sets = try await repo.fetchSets(sessionID: sessionID)
        let totalVolume = sets.map { $0.volume }.reduce(0, +)

        let expectedVolume = (80.0 * 10) + (85.0 * 8) // 800 + 680 = 1480
        XCTAssertEqual(totalVolume, expectedVolume, accuracy: 0.01)
    }

    func test_sessionVolumeCalculation_reflectsDeletedSets() async throws {
        // Given
        let sessionID = UUID().uuidString
        let session = WorkoutSession(id: sessionID, date: Date(), note: "Test session")
        try await repo.create(session: session)

        let set1 = SetRecord(id: UUID().uuidString, sessionID: sessionID, exerciseID: "squat", weight: 100.0, reps: 5, order: 0)
        let set2 = SetRecord(id: UUID().uuidString, sessionID: sessionID, exerciseID: "squat", weight: 105.0, reps: 5, order: 1)

        try await repo.add(set: set1)
        try await repo.add(set: set2)

        // When - Delete one set
        try await repo.deleteSet(id: set1.id)

        // Then - Volume should reflect only remaining set
        let remainingSets = try await repo.fetchSets(sessionID: sessionID)
        let totalVolume = remainingSets.map { $0.volume }.reduce(0, +)

        let expectedVolume = 105.0 * 5 // Only set2 remains: 525
        XCTAssertEqual(totalVolume, expectedVolume, accuracy: 0.01)
        XCTAssertEqual(remainingSets.count, 1)
    }

    func test_sessionVolumeCalculation_reflectsUpdatedSets() async throws {
        // Given
        let sessionID = UUID().uuidString
        let session = WorkoutSession(id: sessionID, date: Date(), note: "Test session")
        try await repo.create(session: session)

        let originalSet = SetRecord(id: UUID().uuidString, sessionID: sessionID, exerciseID: "deadlift", weight: 140.0, reps: 5, order: 0)
        try await repo.add(set: originalSet)

        // When - Update the set
        let updatedSet = SetRecord(
            id: originalSet.id,
            sessionID: originalSet.sessionID,
            exerciseID: originalSet.exerciseID,
            weight: 150.0, // Changed weight
            reps: 3,       // Changed reps
            order: originalSet.order
        )
        try await repo.update(set: updatedSet)

        // Then - Volume should reflect updated values
        let sets = try await repo.fetchSets(sessionID: sessionID)
        let totalVolume = sets.map { $0.volume }.reduce(0, +)

        let expectedVolume = 150.0 * 3 // 450
        XCTAssertEqual(totalVolume, expectedVolume, accuracy: 0.01)
        XCTAssertEqual(sets.count, 1)
        XCTAssertEqual(sets.first?.weight, 150.0)
        XCTAssertEqual(sets.first?.reps, 3)
    }
}