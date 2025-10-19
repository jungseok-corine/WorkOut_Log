//
//  SessionListViewModelTests.swift
//  WorkOut Log
//
//  Created by Claude on 18/10/2025.
//

import XCTest
@testable import workout_log

@MainActor
final class SessionListViewModelTests: XCTestCase {
    var container: AppContainer!
    var viewModel: SessionListViewModel!
    var sessionRepo: InMemorySessionRepository!

    override func setUp() async throws {
        // Use in-memory repositories for testing
        sessionRepo = InMemorySessionRepository()
        let exerciseRepo = InMemoryExerciseRepository()

        container = AppContainer(
            sessionRepo: sessionRepo,
            exerciseRepo: exerciseRepo
        )
        viewModel = SessionListViewModel(container: container)
    }

    override func tearDown() async throws {
        container = nil
        viewModel = nil
        sessionRepo = nil
    }

    // MARK: - Sorting Tests

    func test_refresh_displays_sessions_in_date_descending_order() async throws {
        // Given: Three sessions created out of order
        let cal = Calendar.current
        let now = Date()
        let d0 = cal.date(byAdding: .day, value: -5, to: now)!
        let d1 = cal.date(byAdding: .day, value: -3, to: now)!
        let d2 = cal.date(byAdding: .day, value: -1, to: now)!

        try await sessionRepo.create(session: WorkoutSession(id: "s1", date: d1, note: nil))
        try await sessionRepo.create(session: WorkoutSession(id: "s0", date: d0, note: nil))
        try await sessionRepo.create(session: WorkoutSession(id: "s2", date: d2, note: nil))

        // When: refreshing ViewModel
        await viewModel.refresh()

        // Then: sessions should be in date descending order
        XCTAssertEqual(viewModel.sessions.count, 3)
        XCTAssertEqual(viewModel.sessions[0].id, "s2", "Most recent should be first")
        XCTAssertEqual(viewModel.sessions[1].id, "s1", "Middle date should be second")
        XCTAssertEqual(viewModel.sessions[2].id, "s0", "Oldest should be last")
    }

    func test_createToday_adds_session_at_top() async throws {
        // Given: Existing sessions from previous days
        let cal = Calendar.current
        let now = Date()
        let yesterday = cal.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = cal.date(byAdding: .day, value: -2, to: now)!

        try await sessionRepo.create(session: WorkoutSession(id: "old1", date: yesterday, note: nil))
        try await sessionRepo.create(session: WorkoutSession(id: "old2", date: twoDaysAgo, note: nil))
        await viewModel.refresh()

        XCTAssertEqual(viewModel.sessions.count, 2, "Should start with 2 sessions")

        // When: creating a new session today
        viewModel.createToday()

        // Wait for async operation to complete
        try await Task.sleep(for: .milliseconds(100))

        // Then: new session should appear at index 0
        XCTAssertEqual(viewModel.sessions.count, 3, "Should have 3 sessions after creation")

        // The new session should be at the top (most recent date)
        let firstSessionDate = viewModel.sessions[0].date
        let isToday = cal.isDateInToday(firstSessionDate)
        XCTAssertTrue(isToday, "First session should be today's session")
        XCTAssertEqual(viewModel.sessions[1].id, "old1", "Yesterday's session should be second")
        XCTAssertEqual(viewModel.sessions[2].id, "old2", "Oldest session should be last")
    }

    func test_sessions_maintain_order_after_refresh() async throws {
        // Given: Sessions with specific order
        let cal = Calendar.current
        let now = Date()
        let dates = [
            cal.date(byAdding: .day, value: -1, to: now)!,
            cal.date(byAdding: .day, value: -2, to: now)!,
            cal.date(byAdding: .day, value: -3, to: now)!
        ]

        for (i, date) in dates.enumerated() {
            try await sessionRepo.create(session: WorkoutSession(id: "s\(i)", date: date, note: nil))
        }

        // When: refreshing multiple times
        await viewModel.refresh()
        let firstOrder = viewModel.sessions.map { $0.id }

        await viewModel.refresh()
        let secondOrder = viewModel.sessions.map { $0.id }

        // Then: order should be consistent
        XCTAssertEqual(firstOrder, secondOrder, "Order should be stable across refreshes")
        XCTAssertEqual(firstOrder, ["s0", "s1", "s2"], "Should maintain date descending order")
    }

    func test_equal_dates_maintain_stable_order() async throws {
        // Given: Multiple sessions on the same date
        let date = Date()
        try await sessionRepo.create(session: WorkoutSession(id: "c", date: date, note: nil))
        try await sessionRepo.create(session: WorkoutSession(id: "a", date: date, note: nil))
        try await sessionRepo.create(session: WorkoutSession(id: "b", date: date, note: nil))

        // When: refreshing
        await viewModel.refresh()

        // Then: should be in stable order (by id)
        XCTAssertEqual(viewModel.sessions.count, 3)
        let ids = viewModel.sessions.map { $0.id }
        XCTAssertEqual(ids, ["a", "b", "c"], "Equal dates should use id ascending as tie-breaker")
    }

    func test_deleteSession_maintains_order_of_remaining_sessions() async throws {
        // Given: Three sessions
        let cal = Calendar.current
        let now = Date()
        let d0 = cal.date(byAdding: .day, value: -3, to: now)!
        let d1 = cal.date(byAdding: .day, value: -2, to: now)!
        let d2 = cal.date(byAdding: .day, value: -1, to: now)!

        try await sessionRepo.create(session: WorkoutSession(id: "s0", date: d0, note: nil))
        try await sessionRepo.create(session: WorkoutSession(id: "s1", date: d1, note: nil))
        try await sessionRepo.create(session: WorkoutSession(id: "s2", date: d2, note: nil))
        await viewModel.refresh()

        XCTAssertEqual(viewModel.sessions.count, 3)

        // When: deleting middle session
        viewModel.deleteSession(id: "s1")
        try await Task.sleep(for: .milliseconds(100))

        // Then: remaining sessions should maintain order
        XCTAssertEqual(viewModel.sessions.count, 2)
        XCTAssertEqual(viewModel.sessions[0].id, "s2", "Most recent should still be first")
        XCTAssertEqual(viewModel.sessions[1].id, "s0", "Oldest should still be last")
    }
}
