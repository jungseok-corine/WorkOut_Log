//
//  SessionRepositorySortTests.swift
//  WorkOut Log
//
//  Created by Claude on 18/10/2025.
//

import XCTest
import SwiftData
@testable import workout_log

@MainActor
final class SessionRepositorySortTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var repository: SessionRepositoryImpl!

    override func setUp() async throws {
        // Create in-memory model container for testing
        let schema = Schema([
            ExerciseModel.self,
            SetRecordModel.self,
            WorkoutSessionModel.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)
        repository = SessionRepositoryImpl(context: modelContext)
    }

    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        repository = nil
    }

    // MARK: - fetchAll() Sorting Tests

    func test_fetchAll_returns_sessions_sorted_by_date_descending() async throws {
        // Given: Three sessions with dates D0 < D1 < D2
        let cal = Calendar.current
        let now = Date()
        let d0 = cal.date(byAdding: .day, value: -2, to: now)! // 2 days ago
        let d1 = cal.date(byAdding: .day, value: -1, to: now)! // 1 day ago
        let d2 = now // today

        let session0 = WorkoutSession(id: "s0", date: d0, note: "Day 0")
        let session1 = WorkoutSession(id: "s1", date: d1, note: "Day 1")
        let session2 = WorkoutSession(id: "s2", date: d2, note: "Day 2")

        // Create in random order
        try await repository.create(session: session1)
        try await repository.create(session: session0)
        try await repository.create(session: session2)

        // When: fetching all sessions
        let results = try await repository.fetchAll()

        // Then: should return [D2, D1, D0] (most recent first)
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].id, "s2", "Most recent session should be first")
        XCTAssertEqual(results[1].id, "s1", "Middle session should be second")
        XCTAssertEqual(results[2].id, "s0", "Oldest session should be last")
    }

    func test_fetchAll_stable_sort_with_equal_dates() async throws {
        // Given: Three sessions on the same date with different IDs
        let date = Date()
        let sessionA = WorkoutSession(id: "a", date: date, note: "Session A")
        let sessionB = WorkoutSession(id: "b", date: date, note: "Session B")
        let sessionC = WorkoutSession(id: "c", date: date, note: "Session C")

        // Create in random order
        try await repository.create(session: sessionC)
        try await repository.create(session: sessionA)
        try await repository.create(session: sessionB)

        // When: fetching all sessions
        let results = try await repository.fetchAll()

        // Then: should be sorted by id ascending (stable tie-breaker)
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].id, "a", "ID 'a' should come first")
        XCTAssertEqual(results[1].id, "b", "ID 'b' should come second")
        XCTAssertEqual(results[2].id, "c", "ID 'c' should come third")
    }

    // MARK: - fetchRange() Sorting Tests

    func test_fetchRange_returns_sessions_sorted_by_date_descending() async throws {
        // Given: Three sessions within range
        let cal = Calendar.current
        let now = Date()
        let d0 = cal.date(byAdding: .day, value: -5, to: now)! // 5 days ago
        let d1 = cal.date(byAdding: .day, value: -3, to: now)! // 3 days ago
        let d2 = cal.date(byAdding: .day, value: -1, to: now)! // 1 day ago

        let session0 = WorkoutSession(id: "s0", date: d0, note: "Day 0")
        let session1 = WorkoutSession(id: "s1", date: d1, note: "Day 1")
        let session2 = WorkoutSession(id: "s2", date: d2, note: "Day 2")

        try await repository.create(session: session1)
        try await repository.create(session: session0)
        try await repository.create(session: session2)

        // When: fetching range covering all sessions
        let start = cal.date(byAdding: .day, value: -7, to: now)!
        let end = cal.date(byAdding: .day, value: 1, to: now)!
        let results = try await repository.fetchRange(start: start, end: end)

        // Then: should return [D2, D1, D0]
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].id, "s2")
        XCTAssertEqual(results[1].id, "s1")
        XCTAssertEqual(results[2].id, "s0")
    }

    func test_fetchRange_filters_and_sorts_correctly() async throws {
        // Given: Sessions inside and outside range
        let cal = Calendar.current
        let now = Date()
        let d0 = cal.date(byAdding: .day, value: -10, to: now)! // outside range
        let d1 = cal.date(byAdding: .day, value: -3, to: now)!  // inside
        let d2 = cal.date(byAdding: .day, value: -1, to: now)!  // inside

        try await repository.create(session: WorkoutSession(id: "s0", date: d0, note: nil))
        try await repository.create(session: WorkoutSession(id: "s1", date: d1, note: nil))
        try await repository.create(session: WorkoutSession(id: "s2", date: d2, note: nil))

        // When: fetching range for last 7 days
        let start = cal.date(byAdding: .day, value: -7, to: now)!
        let end = cal.date(byAdding: .day, value: 1, to: now)!
        let results = try await repository.fetchRange(start: start, end: end)

        // Then: should return only [D2, D1]
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].id, "s2")
        XCTAssertEqual(results[1].id, "s1")
    }

    // MARK: - latest() Sorting Test

    func test_latest_returns_most_recent_session() async throws {
        // Given: Three sessions with different dates
        let cal = Calendar.current
        let now = Date()
        let d0 = cal.date(byAdding: .day, value: -5, to: now)!
        let d1 = cal.date(byAdding: .day, value: -3, to: now)!
        let d2 = cal.date(byAdding: .day, value: -1, to: now)! // most recent

        try await repository.create(session: WorkoutSession(id: "s0", date: d0, note: nil))
        try await repository.create(session: WorkoutSession(id: "s1", date: d1, note: nil))
        try await repository.create(session: WorkoutSession(id: "s2", date: d2, note: nil))

        // When: fetching latest
        let latest = try await repository.latest()

        // Then: should return s2
        XCTAssertNotNil(latest)
        XCTAssertEqual(latest?.id, "s2", "Latest session should be the most recent one")
    }

    func test_latest_with_equal_dates_uses_stable_tiebreaker() async throws {
        // Given: Two sessions on the same date
        let date = Date()
        try await repository.create(session: WorkoutSession(id: "z", date: date, note: nil))
        try await repository.create(session: WorkoutSession(id: "a", date: date, note: nil))

        // When: fetching latest
        let latest = try await repository.latest()

        // Then: should return 'a' (lower ID wins tie)
        XCTAssertNotNil(latest)
        XCTAssertEqual(latest?.id, "a", "Stable tie-breaker should use id ascending")
    }

    // MARK: - Update Date and Re-sort Test

    func test_update_session_date_reorders_correctly() async throws {
        // Given: Three sessions
        let cal = Calendar.current
        let now = Date()
        let d0 = cal.date(byAdding: .day, value: -5, to: now)!
        let d1 = cal.date(byAdding: .day, value: -3, to: now)!
        let d2 = cal.date(byAdding: .day, value: -1, to: now)!

        try await repository.create(session: WorkoutSession(id: "s0", date: d0, note: nil))
        try await repository.create(session: WorkoutSession(id: "s1", date: d1, note: nil))
        try await repository.create(session: WorkoutSession(id: "s2", date: d2, note: nil))

        // When: updating s0 to have the most recent date
        let newDate = cal.date(byAdding: .day, value: 1, to: now)! // tomorrow
        try await repository.update(session: WorkoutSession(id: "s0", date: newDate, note: "Updated"))

        let results = try await repository.fetchAll()

        // Then: s0 should now be first
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].id, "s0", "Updated session should move to top")
        XCTAssertEqual(results[1].id, "s2")
        XCTAssertEqual(results[2].id, "s1")
    }

    func test_update_session_date_to_older_moves_down() async throws {
        // Given: Three sessions
        let cal = Calendar.current
        let now = Date()
        let d0 = cal.date(byAdding: .day, value: -5, to: now)!
        let d1 = cal.date(byAdding: .day, value: -3, to: now)!
        let d2 = cal.date(byAdding: .day, value: -1, to: now)!

        try await repository.create(session: WorkoutSession(id: "s0", date: d0, note: nil))
        try await repository.create(session: WorkoutSession(id: "s1", date: d1, note: nil))
        try await repository.create(session: WorkoutSession(id: "s2", date: d2, note: nil))

        // When: updating s2 (most recent) to oldest date
        let oldDate = cal.date(byAdding: .day, value: -10, to: now)!
        try await repository.update(session: WorkoutSession(id: "s2", date: oldDate, note: "Old"))

        let results = try await repository.fetchAll()

        // Then: s2 should move to bottom
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].id, "s1", "s1 should now be first")
        XCTAssertEqual(results[1].id, "s0", "s0 should be second")
        XCTAssertEqual(results[2].id, "s2", "Updated session should move to bottom")
    }

    // MARK: - Create New Session Appears at Top

    func test_create_new_session_with_today_date_appears_at_top() async throws {
        // Given: Existing sessions from previous days
        let cal = Calendar.current
        let now = Date()
        let yesterday = cal.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = cal.date(byAdding: .day, value: -2, to: now)!

        try await repository.create(session: WorkoutSession(id: "old1", date: yesterday, note: nil))
        try await repository.create(session: WorkoutSession(id: "old2", date: twoDaysAgo, note: nil))

        // When: creating a new session with today's date
        let newSession = WorkoutSession(id: "new", date: now, note: "Today")
        try await repository.create(session: newSession)

        let results = try await repository.fetchAll()

        // Then: new session should appear at index 0
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].id, "new", "Newly created session should be at top")
        XCTAssertEqual(results[1].id, "old1")
        XCTAssertEqual(results[2].id, "old2")
    }
}
