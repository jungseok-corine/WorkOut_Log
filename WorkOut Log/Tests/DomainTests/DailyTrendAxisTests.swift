//
//  DailyTrendAxisTests.swift
//  WorkOut Log
//
//  Created by Claude on 18/10/2025.
//

import XCTest
@testable import workout_log

final class DailyTrendAxisTests: XCTestCase {
    func test_daily_trend_returns_max_10_points() async throws {
        // Given: repository with sessions across 15 days
        let sessionRepo = InMemorySessionRepository()
        let exerciseRepo = InMemoryExerciseRepository()
        let useCase = ComputeVolumeTrendUseCase(sessionRepo: sessionRepo, exerciseRepo: exerciseRepo)

        let exercise = Exercise(id: "ex1", name: "Squat", main: .lowerBody)
        try await exerciseRepo.upsert(exercise)

        let calendar = Calendar(identifier: .iso8601)
        let now = Date()

        // Create sessions across 15 different days
        for dayOffset in -14...0 {
            let sessionDate = calendar.date(byAdding: .day, value: dayOffset, to: now)!
            let session = WorkoutSession(id: "s\(dayOffset)", date: sessionDate, note: nil)
            try await sessionRepo.create(session: session)

            let set = SetRecord(id: "set\(dayOffset)", sessionID: session.id, exerciseID: exercise.id,
                              weight: 100, reps: 10, order: 0)
            try await sessionRepo.add(set: set)
        }

        // When: computing daily trend
        let trend = try await useCase(scope: .daily, categoryFilter: nil, includeZeroDays: false)

        // Then: should return at most 10 points
        XCTAssertLessThanOrEqual(trend.count, 10, "Daily trend should cap at 10 points")
        XCTAssertEqual(trend.count, 10, "With 15 days of data, should return exactly 10 (latest)")
    }

    func test_daily_trend_points_ordered_ascending() async throws {
        // Given: repository with sessions across multiple days
        let sessionRepo = InMemorySessionRepository()
        let exerciseRepo = InMemoryExerciseRepository()
        let useCase = ComputeVolumeTrendUseCase(sessionRepo: sessionRepo, exerciseRepo: exerciseRepo)

        let exercise = Exercise(id: "ex1", name: "Bench Press", main: .upperBody)
        try await exerciseRepo.upsert(exercise)

        let calendar = Calendar(identifier: .iso8601)
        let now = Date()

        // Create sessions on 5 different days (out of order)
        let dayOffsets = [-8, -3, -1, -5, -10]
        for dayOffset in dayOffsets {
            let sessionDate = calendar.date(byAdding: .day, value: dayOffset, to: now)!
            let session = WorkoutSession(id: "s\(dayOffset)", date: sessionDate, note: nil)
            try await sessionRepo.create(session: session)

            let set = SetRecord(id: "set\(dayOffset)", sessionID: session.id, exerciseID: exercise.id,
                              weight: 80, reps: 8, order: 0)
            try await sessionRepo.add(set: set)
        }

        // When: computing daily trend
        let trend = try await useCase(scope: .daily, categoryFilter: nil, includeZeroDays: false)

        // Then: dates should be in ascending order
        let dates = trend.map { $0.date }
        let sortedDates = dates.sorted()
        XCTAssertEqual(dates, sortedDates, "Daily trend dates must be in ascending order for proper axis mapping")
    }

    func test_daily_trend_with_zero_days_still_caps_at_10() async throws {
        // Given: repository with sparse data
        let sessionRepo = InMemorySessionRepository()
        let exerciseRepo = InMemoryExerciseRepository()
        let useCase = ComputeVolumeTrendUseCase(sessionRepo: sessionRepo, exerciseRepo: exerciseRepo)

        let exercise = Exercise(id: "ex1", name: "Deadlift", main: .fullBody)
        try await exerciseRepo.upsert(exercise)

        let calendar = Calendar(identifier: .iso8601)
        let now = Date()

        // Create sessions only on 3 days
        for dayOffset in [-20, -10, -2] {
            let sessionDate = calendar.date(byAdding: .day, value: dayOffset, to: now)!
            let session = WorkoutSession(id: "s\(dayOffset)", date: sessionDate, note: nil)
            try await sessionRepo.create(session: session)

            let set = SetRecord(id: "set\(dayOffset)", sessionID: session.id, exerciseID: exercise.id,
                              weight: 120, reps: 5, order: 0)
            try await sessionRepo.add(set: set)
        }

        // When: computing daily trend WITH includeZeroDays
        let trendWithZeros = try await useCase(scope: .daily, categoryFilter: nil, includeZeroDays: true)

        // Then: should still cap at 10 points (latest 10 days from 30-day window)
        XCTAssertLessThanOrEqual(trendWithZeros.count, 10, "Daily trend with zero days should still cap at 10")
        XCTAssertEqual(trendWithZeros.count, 10, "Should return last 10 days from 30-day window")
    }

    func test_daily_trend_dates_unique() async throws {
        // Given: repository with multiple sessions on same day
        let sessionRepo = InMemorySessionRepository()
        let exerciseRepo = InMemoryExerciseRepository()
        let useCase = ComputeVolumeTrendUseCase(sessionRepo: sessionRepo, exerciseRepo: exerciseRepo)

        let exercise = Exercise(id: "ex1", name: "Pull Up", main: .upperBody)
        try await exerciseRepo.upsert(exercise)

        let calendar = Calendar(identifier: .iso8601)
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)

        // Create 3 sessions on the same day
        for i in 0..<3 {
            let sessionDate = calendar.date(byAdding: .hour, value: i * 4, to: todayStart)!
            let session = WorkoutSession(id: "s\(i)", date: sessionDate, note: nil)
            try await sessionRepo.create(session: session)

            let set = SetRecord(id: "set\(i)", sessionID: session.id, exerciseID: exercise.id,
                              weight: 50 + Double(i * 10), reps: 10, order: 0)
            try await sessionRepo.add(set: set)
        }

        // When: computing daily trend
        let trend = try await useCase(scope: .daily, categoryFilter: nil, includeZeroDays: false)

        // Then: should only have 1 point for today (dates aggregated by day)
        XCTAssertEqual(trend.count, 1, "Multiple sessions on same day should aggregate to one point")

        // Volume should be sum of all sets
        let totalVolume = trend[0].volume
        let expectedVolume = (50 * 10) + (60 * 10) + (70 * 10) // 500 + 600 + 700 = 1800
        XCTAssertEqual(totalVolume, expectedVolume, "Volume should aggregate all sets from same day")
    }
}
