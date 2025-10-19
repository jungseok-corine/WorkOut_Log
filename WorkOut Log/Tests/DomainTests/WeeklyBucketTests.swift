//
//  WeeklyBucketTests.swift
//  WorkOut Log
//
//  Created by Claude on 18/10/2025.
//

import XCTest
@testable import workout_log

final class WeeklyBucketTests: XCTestCase {
    func test_weekly_uses_sunday_start_buckets() async throws {
        // Given: Sunday-Saturday week definition (Oct 6–12, 2024)
        let sessionRepo = InMemorySessionRepository()
        let exerciseRepo = InMemoryExerciseRepository()
        let useCase = ComputeVolumeTrendUseCase(sessionRepo: sessionRepo, exerciseRepo: exerciseRepo)

        let exercise = Exercise(id: "ex1", name: "Squat", main: .lowerBody)
        try await exerciseRepo.upsert(exercise)

        // Create a Gregorian Sunday-start calendar for test setup
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1 // Sunday = 1

        // Oct 6, 2024 is a Sunday
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = calendar
        let sunday = dateFormatter.date(from: "2024-10-06")! // Sunday
        let monday = calendar.date(byAdding: .day, value: 1, to: sunday)! // Oct 7
        let saturday = calendar.date(byAdding: .day, value: 6, to: sunday)! // Oct 12

        // Create sessions on Sunday (week start), Monday, and Saturday (week end)
        for (offset, date) in [0: sunday, 1: monday, 6: saturday] {
            let session = WorkoutSession(id: "s\(offset)", date: date, note: nil)
            try await sessionRepo.create(session: session)

            let set = SetRecord(id: "set\(offset)", sessionID: session.id, exerciseID: exercise.id,
                              weight: 100, reps: 10, order: 0)
            try await sessionRepo.add(set: set)
        }

        // When: computing weekly trend
        let trend = try await useCase(scope: .weekly, categoryFilter: nil)

        // Then: all three sessions should be in the same week bucket
        let weekWithData = trend.first { $0.volume > 0 }
        XCTAssertNotNil(weekWithData, "Should have at least one week with data")

        // The week start should be Sunday Oct 6
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: sunday)!.start
        XCTAssertEqual(weekWithData?.date, weekStart, "Week should start on Sunday Oct 6")

        // Volume should be sum of all three days (3 sets × 100kg × 10 reps = 3000)
        XCTAssertEqual(weekWithData?.volume, 3000.0, "All sessions from Sun–Sat should aggregate into one bucket")
    }

    func test_weekly_boundary_sessions_go_to_correct_buckets() async throws {
        // Given: Two consecutive weeks
        let sessionRepo = InMemorySessionRepository()
        let exerciseRepo = InMemoryExerciseRepository()
        let useCase = ComputeVolumeTrendUseCase(sessionRepo: sessionRepo, exerciseRepo: exerciseRepo)

        let exercise = Exercise(id: "ex1", name: "Bench Press", main: .upperBody)
        try await exerciseRepo.upsert(exercise)

        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1 // Sunday = 1

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = calendar

        // Week 1: Oct 6 (Sun) – Oct 12 (Sat)
        let week1Saturday = dateFormatter.date(from: "2024-10-12")! // Saturday

        // Week 2: Oct 13 (Sun) – Oct 19 (Sat)
        let week2Sunday = dateFormatter.date(from: "2024-10-13")! // Sunday (next week)

        // Create session on Saturday (end of week 1)
        let saturdaySession = WorkoutSession(id: "s1", date: week1Saturday, note: nil)
        try await sessionRepo.create(session: saturdaySession)
        let saturdaySet = SetRecord(id: "set1", sessionID: saturdaySession.id, exerciseID: exercise.id,
                                   weight: 80, reps: 10, order: 0)
        try await sessionRepo.add(set: saturdaySet)

        // Create session on Sunday (start of week 2)
        let sundaySession = WorkoutSession(id: "s2", date: week2Sunday, note: nil)
        try await sessionRepo.create(session: sundaySession)
        let sundaySet = SetRecord(id: "set2", sessionID: sundaySession.id, exerciseID: exercise.id,
                                 weight: 100, reps: 10, order: 0)
        try await sessionRepo.add(set: sundaySet)

        // When: computing weekly trend
        let trend = try await useCase(scope: .weekly, categoryFilter: nil)

        // Then: should have two separate weeks with different volumes
        let weeksWithData = trend.filter { $0.volume > 0 }
        XCTAssertEqual(weeksWithData.count, 2, "Should have exactly 2 weeks with data")

        // Week 1 should have Saturday's volume (800)
        let week1Start = calendar.dateInterval(of: .weekOfYear, for: week1Saturday)!.start
        let week1Data = trend.first { $0.date == week1Start }
        XCTAssertEqual(week1Data?.volume, 800.0, "Week 1 should have Saturday's volume")

        // Week 2 should have Sunday's volume (1000)
        let week2Start = calendar.dateInterval(of: .weekOfYear, for: week2Sunday)!.start
        let week2Data = trend.first { $0.date == week2Start }
        XCTAssertEqual(week2Data?.volume, 1000.0, "Week 2 should have Sunday's volume")

        // Week starts should be different Sundays
        XCTAssertNotEqual(week1Start, week2Start, "Week starts should be different")
    }

    func test_weekly_returns_8_weeks_with_zeros() async throws {
        // Given: Sparse data
        let sessionRepo = InMemorySessionRepository()
        let exerciseRepo = InMemoryExerciseRepository()
        let useCase = ComputeVolumeTrendUseCase(sessionRepo: sessionRepo, exerciseRepo: exerciseRepo)

        let exercise = Exercise(id: "ex1", name: "Deadlift", main: .fullBody)
        try await exerciseRepo.upsert(exercise)

        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1

        let now = Date()
        let threeWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -3, to: now)!

        // Create one session 3 weeks ago
        let session = WorkoutSession(id: "s1", date: threeWeeksAgo, note: nil)
        try await sessionRepo.create(session: session)
        let set = SetRecord(id: "set1", sessionID: session.id, exerciseID: exercise.id,
                          weight: 120, reps: 5, order: 0)
        try await sessionRepo.add(set: set)

        // When: computing weekly trend
        let trend = try await useCase(scope: .weekly, categoryFilter: nil)

        // Then: should return exactly 8 weeks
        XCTAssertEqual(trend.count, 8, "Weekly trend should return 8 weeks")

        // Only one week should have non-zero volume
        let weeksWithVolume = trend.filter { $0.volume > 0 }
        XCTAssertEqual(weeksWithVolume.count, 1, "Only one week should have volume")

        // 7 weeks should have zero volume
        let weeksWithZero = trend.filter { $0.volume == 0 }
        XCTAssertEqual(weeksWithZero.count, 7, "7 weeks should have zero volume")
    }

    func test_weekly_aggregates_multiple_days_in_same_week() async throws {
        // Given: Sessions scattered across one week
        let sessionRepo = InMemorySessionRepository()
        let exerciseRepo = InMemoryExerciseRepository()
        let useCase = ComputeVolumeTrendUseCase(sessionRepo: sessionRepo, exerciseRepo: exerciseRepo)

        let exercise = Exercise(id: "ex1", name: "Pull Up", main: .upperBody)
        try await exerciseRepo.upsert(exercise)

        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = calendar

        // Oct 6–12, 2024: Sun, Tue, Thu, Sat
        let days = [
            dateFormatter.date(from: "2024-10-06")!, // Sunday
            dateFormatter.date(from: "2024-10-08")!, // Tuesday
            dateFormatter.date(from: "2024-10-10")!, // Thursday
            dateFormatter.date(from: "2024-10-12")!  // Saturday
        ]

        for (i, date) in days.enumerated() {
            let session = WorkoutSession(id: "s\(i)", date: date, note: nil)
            try await sessionRepo.create(session: session)

            let set = SetRecord(id: "set\(i)", sessionID: session.id, exerciseID: exercise.id,
                              weight: Double(50 + i * 10), reps: 10, order: 0)
            try await sessionRepo.add(set: set)
        }

        // When: computing weekly trend
        let trend = try await useCase(scope: .weekly, categoryFilter: nil)

        // Then: all 4 sessions should aggregate into one week
        let weekWithData = trend.first { $0.volume > 0 }
        XCTAssertNotNil(weekWithData)

        // Volume: (50×10) + (60×10) + (70×10) + (80×10) = 500 + 600 + 700 + 800 = 2600
        XCTAssertEqual(weekWithData?.volume, 2600.0, "All 4 sessions should aggregate into one week")
    }

    func test_weekly_respects_category_filter() async throws {
        // Given: Sessions with different exercise categories in same week
        let sessionRepo = InMemorySessionRepository()
        let exerciseRepo = InMemoryExerciseRepository()
        let useCase = ComputeVolumeTrendUseCase(sessionRepo: sessionRepo, exerciseRepo: exerciseRepo)

        let upperExercise = Exercise(id: "ex1", name: "Bench Press", main: .upperBody)
        let lowerExercise = Exercise(id: "ex2", name: "Squat", main: .lowerBody)
        try await exerciseRepo.upsert(upperExercise)
        try await exerciseRepo.upsert(lowerExercise)

        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = calendar

        let sunday = dateFormatter.date(from: "2024-10-06")! // Sunday
        let monday = calendar.date(byAdding: .day, value: 1, to: sunday)! // Monday

        // Upper body on Sunday
        let upperSession = WorkoutSession(id: "s1", date: sunday, note: nil)
        try await sessionRepo.create(session: upperSession)
        let upperSet = SetRecord(id: "set1", sessionID: upperSession.id, exerciseID: upperExercise.id,
                               weight: 80, reps: 10, order: 0)
        try await sessionRepo.add(set: upperSet)

        // Lower body on Monday
        let lowerSession = WorkoutSession(id: "s2", date: monday, note: nil)
        try await sessionRepo.create(session: lowerSession)
        let lowerSet = SetRecord(id: "set2", sessionID: lowerSession.id, exerciseID: lowerExercise.id,
                               weight: 100, reps: 10, order: 0)
        try await sessionRepo.add(set: lowerSet)

        // When: computing weekly trend with upperBody filter
        let upperTrend = try await useCase(scope: .weekly, categoryFilter: .upperBody)
        let lowerTrend = try await useCase(scope: .weekly, categoryFilter: .lowerBody)

        // Then: filtered trends should show only their category's volume
        let upperWeek = upperTrend.first { $0.volume > 0 }
        let lowerWeek = lowerTrend.first { $0.volume > 0 }

        XCTAssertEqual(upperWeek?.volume, 800.0, "Upper body filter should show only upper volume")
        XCTAssertEqual(lowerWeek?.volume, 1000.0, "Lower body filter should show only lower volume")
    }
}
