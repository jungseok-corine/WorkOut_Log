//
//  SetCRUDTests.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import XCTest
@testable import workout_log

final class SetCRUDTests: XCTestCase {
    var repo: InMemorySessionRepository!
    var addUseCase: AddSetUseCase!
    var updateUseCase: UpdateSetUseCase!
    var deleteUseCase: DeleteSetUseCase!
    var sessionID: String!

    override func setUpWithError() throws {
        repo = InMemorySessionRepository()
        addUseCase = AddSetUseCase(repo: repo)
        updateUseCase = UpdateSetUseCase(repo: repo)
        deleteUseCase = DeleteSetUseCase(repo: repo)
        sessionID = UUID().uuidString

        // Create a test session synchronously in the in-memory repo
        let session = WorkoutSession(id: sessionID, date: Date(), note: "Test session")
        Task {
            try await repo.create(session: session)
        }
    }

    func test_setLifecycle_createUpdateDelete() async throws {
        // CREATE
        let originalSet = try await addUseCase(
            sessionID: sessionID,
            exerciseID: "bench-press",
            weight: 80.0,
            reps: 10,
            order: 0
        )

        XCTAssertEqual(originalSet.weight, 80.0)
        XCTAssertEqual(originalSet.reps, 10)
        XCTAssertEqual(originalSet.volume, 800.0)

        // Verify in repository
        var sets = try await repo.fetchSets(sessionID: sessionID)
        XCTAssertEqual(sets.count, 1)
        XCTAssertEqual(sets.first?.id, originalSet.id)

        // UPDATE
        let updatedSet = try await updateUseCase(
            set: originalSet,
            newWeight: 85.0,
            newReps: 8
        )

        XCTAssertEqual(updatedSet.weight, 85.0)
        XCTAssertEqual(updatedSet.reps, 8)
        XCTAssertEqual(updatedSet.volume, 680.0)
        XCTAssertEqual(updatedSet.id, originalSet.id) // ID should remain same

        // Verify update in repository
        sets = try await repo.fetchSets(sessionID: sessionID)
        XCTAssertEqual(sets.count, 1)
        let fetchedSet = sets.first!
        XCTAssertEqual(fetchedSet.weight, 85.0)
        XCTAssertEqual(fetchedSet.reps, 8)

        // DELETE
        try await deleteUseCase(setID: originalSet.id)

        // Verify deletion
        sets = try await repo.fetchSets(sessionID: sessionID)
        XCTAssertEqual(sets.count, 0)
    }

    func test_addMultipleSets_maintainsOrder() async throws {
        // Add sets in order
        let set1 = try await addUseCase(sessionID: sessionID, exerciseID: "squat", weight: 100.0, reps: 5, order: 0)
        let set2 = try await addUseCase(sessionID: sessionID, exerciseID: "squat", weight: 105.0, reps: 5, order: 1)
        let set3 = try await addUseCase(sessionID: sessionID, exerciseID: "squat", weight: 110.0, reps: 3, order: 2)

        let sets = try await repo.fetchSets(sessionID: sessionID)
        XCTAssertEqual(sets.count, 3)

        // Verify order is maintained
        XCTAssertEqual(sets[0].order, 0)
        XCTAssertEqual(sets[1].order, 1)
        XCTAssertEqual(sets[2].order, 2)

        XCTAssertEqual(sets[0].weight, 100.0)
        XCTAssertEqual(sets[1].weight, 105.0)
        XCTAssertEqual(sets[2].weight, 110.0)
    }

    func test_deleteMiddleSet_doesNotAffectOthers() async throws {
        // Add three sets
        let set1 = try await addUseCase(sessionID: sessionID, exerciseID: "deadlift", weight: 140.0, reps: 5, order: 0)
        let set2 = try await addUseCase(sessionID: sessionID, exerciseID: "deadlift", weight: 150.0, reps: 3, order: 1)
        let set3 = try await addUseCase(sessionID: sessionID, exerciseID: "deadlift", weight: 160.0, reps: 1, order: 2)

        // Delete middle set
        try await deleteUseCase(setID: set2.id)

        let remainingSets = try await repo.fetchSets(sessionID: sessionID)
        XCTAssertEqual(remainingSets.count, 2)

        // Verify correct sets remain
        let remainingIDs = Set(remainingSets.map { $0.id })
        XCTAssertTrue(remainingIDs.contains(set1.id))
        XCTAssertFalse(remainingIDs.contains(set2.id))
        XCTAssertTrue(remainingIDs.contains(set3.id))
    }

    func test_updateSet_preservesOtherProperties() async throws {
        let originalSet = try await addUseCase(
            sessionID: sessionID,
            exerciseID: "overhead-press",
            weight: 60.0,
            reps: 8,
            order: 0
        )

        let updatedSet = try await updateUseCase(
            set: originalSet,
            newWeight: 65.0,
            newReps: 6
        )

        // Weight and reps should change
        XCTAssertEqual(updatedSet.weight, 65.0)
        XCTAssertEqual(updatedSet.reps, 6)

        // Other properties should remain the same
        XCTAssertEqual(updatedSet.id, originalSet.id)
        XCTAssertEqual(updatedSet.sessionID, originalSet.sessionID)
        XCTAssertEqual(updatedSet.exerciseID, originalSet.exerciseID)
        XCTAssertEqual(updatedSet.order, originalSet.order)
    }

}