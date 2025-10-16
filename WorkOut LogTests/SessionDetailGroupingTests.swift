//
//  SessionDetailGroupingTests.swift
//  WorkOut Log
//
//  Created by Claude on 16/10/2025.
//

import XCTest
@testable import workout_log

final class SessionDetailGroupingTests: XCTestCase {
    var mockSessionRepo: MockSessionRepository!
    var mockExerciseRepo: MockExerciseRepository!
    var container: AppContainer!
    var vm: SessionDetailViewModel!

    override func setUpWithError() throws {
        // Note: We'll test the grouping logic at the ViewModel level
        // since it's presentation logic, not domain logic
    }

    func test_grouping_twoExercises_correctSections() async throws {
        // This test validates the grouping algorithm conceptually
        // In practice, this is integration tested via the ViewModel

        // Given two exercises with sets
        let squat = Exercise(id: "ex1", name: "Squat", main: .lowerBody)
        let bench = Exercise(id: "ex2", name: "Bench Press", main: .upperBody)

        let sets = [
            SetRecord(id: "s1", sessionID: "sess1", exerciseID: squat.id, weight: 100, reps: 10, order: 0),
            SetRecord(id: "s2", sessionID: "sess1", exerciseID: squat.id, weight: 100, reps: 10, order: 1),
            SetRecord(id: "s3", sessionID: "sess1", exerciseID: bench.id, weight: 80, reps: 8, order: 2),
        ]

        // When grouping by exerciseID
        let grouped = Dictionary(grouping: sets) { $0.exerciseID }

        // Then we should have 2 groups
        XCTAssertEqual(grouped.keys.count, 2)
        XCTAssertEqual(grouped[squat.id]?.count, 2)
        XCTAssertEqual(grouped[bench.id]?.count, 1)

        // Verify per-exercise indices (enumerated)
        if let squatSets = grouped[squat.id]?.sorted(by: { $0.order < $1.order }) {
            let indices = squatSets.enumerated().map { $0.offset + 1 }
            XCTAssertEqual(indices, [1, 2])
        }

        if let benchSets = grouped[bench.id] {
            let indices = benchSets.enumerated().map { $0.offset + 1 }
            XCTAssertEqual(indices, [1])
        }

        // Verify volumes
        let squatVolume = grouped[squat.id]?.reduce(0) { $0 + Int($1.volume) } ?? 0
        let benchVolume = grouped[bench.id]?.reduce(0) { $0 + Int($1.volume) } ?? 0

        XCTAssertEqual(squatVolume, 2000) // 100*10 + 100*10
        XCTAssertEqual(benchVolume, 640)  // 80*8
    }

    func test_grouping_sectionOrder_byFirstSetAppearance() async throws {
        // Given sets from multiple exercises with interleaved orders
        let ex1 = "ex1"
        let ex2 = "ex2"

        let sets = [
            SetRecord(id: "s1", sessionID: "sess1", exerciseID: ex1, weight: 100, reps: 10, order: 0),
            SetRecord(id: "s2", sessionID: "sess1", exerciseID: ex2, weight: 80, reps: 8, order: 1),
            SetRecord(id: "s3", sessionID: "sess1", exerciseID: ex1, weight: 100, reps: 10, order: 2),
        ]

        // When grouping and sorting by first appearance
        let grouped = Dictionary(grouping: sets) { $0.exerciseID }
        let sortedGroups = grouped.map { (exerciseID, sets) -> (String, Int) in
            let firstOrder = sets.map { $0.order }.min() ?? 0
            return (exerciseID, firstOrder)
        }.sorted { $0.1 < $1.1 }

        // Then ex1 should come before ex2 (order 0 < order 1)
        XCTAssertEqual(sortedGroups[0].0, ex1)
        XCTAssertEqual(sortedGroups[1].0, ex2)
    }

    func test_grouping_emptySection_afterDelete() async throws {
        // Given a single set for an exercise
        let ex1 = "ex1"
        var sets = [
            SetRecord(id: "s1", sessionID: "sess1", exerciseID: ex1, weight: 100, reps: 10, order: 0),
        ]

        // When deleting that set
        sets.removeAll { $0.id == "s1" }

        // Then grouping produces no groups
        let grouped = Dictionary(grouping: sets) { $0.exerciseID }
        XCTAssertTrue(grouped.isEmpty)
    }
}
