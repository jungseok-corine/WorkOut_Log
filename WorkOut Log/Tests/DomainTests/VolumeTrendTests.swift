//
//  VolumeTrendTests.swift
//  WorkOut Log
//
//  Created by Claude on 15/10/2025.
//

import XCTest
@testable import workout_log

final class VolumeTrendTests: XCTestCase {
    func test_weekly_trend_returns_8_weeks() async throws {
        let sessionRepo = InMemorySessionRepository()
        let exerciseRepo = InMemoryExerciseRepository()
        let useCase = ComputeVolumeTrendUseCase(sessionRepo: sessionRepo, exerciseRepo: exerciseRepo)

        // Create exercise
        let exercise = Exercise(id: "ex1", name: "Bench Press", main: .upperBody)
        try await exerciseRepo.upsert(exercise)

        // Create sessions with sets over multiple weeks
        let calendar = Calendar(identifier: .iso8601)
        let now = Date()

        for weekOffset in [-6, -4, -2, 0] {
            let sessionDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: now)!
            let session = WorkoutSession(id: "s\(weekOffset)", date: sessionDate, note: nil)
            try await sessionRepo.create(session: session)

            let set = SetRecord(id: "set\(weekOffset)", sessionID: session.id, exerciseID: exercise.id,
                              weight: 100, reps: 10, order: 0)
            try await sessionRepo.add(set: set)
        }

        // Get trend
        let trend = try await useCase(scope: .weekly, categoryFilter: nil)

        // Should have 8 weeks
        XCTAssertEqual(trend.count, 8)

        // Should have data for 4 weeks
        let nonZeroWeeks = trend.filter { $0.volume > 0 }
        XCTAssertEqual(nonZeroWeeks.count, 4)
    }

    func test_category_filter_works() async throws {
        let sessionRepo = InMemorySessionRepository()
        let exerciseRepo = InMemoryExerciseRepository()
        let useCase = ComputeVolumeTrendUseCase(sessionRepo: sessionRepo, exerciseRepo: exerciseRepo)

        // Create exercises in different categories
        let upperExercise = Exercise(id: "ex1", name: "Bench Press", main: .upperBody)
        let lowerExercise = Exercise(id: "ex2", name: "Squat", main: .lowerBody)
        try await exerciseRepo.upsert(upperExercise)
        try await exerciseRepo.upsert(lowerExercise)

        // Create session with both types
        let session = WorkoutSession(id: "s1", date: Date(), note: nil)
        try await sessionRepo.create(session: session)

        let upperSet = SetRecord(id: "set1", sessionID: session.id, exerciseID: upperExercise.id,
                                weight: 100, reps: 10, order: 0)
        let lowerSet = SetRecord(id: "set2", sessionID: session.id, exerciseID: lowerExercise.id,
                                weight: 200, reps: 10, order: 1)
        try await sessionRepo.add(set: upperSet)
        try await sessionRepo.add(set: lowerSet)

        // Get trend with upperBody filter
        let upperTrend = try await useCase(scope: .weekly, categoryFilter: .upperBody)
        let thisWeekUpper = upperTrend.last!
        XCTAssertEqual(thisWeekUpper.volume, 1000.0) // 100 * 10

        // Get trend with lowerBody filter
        let lowerTrend = try await useCase(scope: .weekly, categoryFilter: .lowerBody)
        let thisWeekLower = lowerTrend.last!
        XCTAssertEqual(thisWeekLower.volume, 2000.0) // 200 * 10

        // Get trend with no filter
        let allTrend = try await useCase(scope: .weekly, categoryFilter: nil)
        let thisWeekAll = allTrend.last!
        XCTAssertEqual(thisWeekAll.volume, 3000.0) // 100*10 + 200*10
    }

    func test_monthly_trend_returns_6_months() async throws {
        let sessionRepo = InMemorySessionRepository()
        let exerciseRepo = InMemoryExerciseRepository()
        let useCase = ComputeVolumeTrendUseCase(sessionRepo: sessionRepo, exerciseRepo: exerciseRepo)

        let trend = try await useCase(scope: .monthly, categoryFilter: nil)

        // Should have 6 months
        XCTAssertEqual(trend.count, 6)
    }
}
