//
//  DeleteSessionUseCaseTests.swift
//  WorkOut Log
//
//  Created by Claude on 15/10/2025.
//

import XCTest
@testable import workout_log

final class DeleteSessionUseCaseTests: XCTestCase {
    func test_delete_session_cascades_to_sets() async throws {
        let repo = InMemorySessionRepository()
        let deleteSessionUC = DeleteSessionUseCase(repo: repo)

        // Create session with sets
        let session = WorkoutSession(id: "s1", date: .now, note: nil)
        try await repo.create(session: session)

        let set1 = SetRecord(id: "set1", sessionID: "s1", exerciseID: "ex1", weight: 100, reps: 10, order: 0)
        let set2 = SetRecord(id: "set2", sessionID: "s1", exerciseID: "ex1", weight: 100, reps: 10, order: 1)
        try await repo.add(set: set1)
        try await repo.add(set: set2)

        // Verify setup
        let fetchedSession = try await repo.fetch(by: "s1")
        XCTAssertNotNil(fetchedSession)
        let sets = try await repo.fetchSets(sessionID: "s1")
        XCTAssertEqual(sets.count, 2)

        // Delete session
        try await deleteSessionUC(sessionID: "s1")

        // Verify session deleted
        let deletedSession = try await repo.fetch(by: "s1")
        XCTAssertNil(deletedSession)

        // Verify sets cascaded
        let remainingSets = try await repo.fetchSets(sessionID: "s1")
        XCTAssertTrue(remainingSets.isEmpty)
    }

    func test_delete_nonexistent_session_does_not_throw() async throws {
        let repo = InMemorySessionRepository()
        let deleteSessionUC = DeleteSessionUseCase(repo: repo)

        // Should not throw even if session doesn't exist
        try await deleteSessionUC(sessionID: "nonexistent")
    }
}
