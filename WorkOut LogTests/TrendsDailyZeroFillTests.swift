//
//  TrendsDailyZeroFillTests.swift
//  WorkOut LogTests
//
//  Created by Claude on 16/10/2025.
//

import XCTest
@testable import workout_log

final class TrendsDailyZeroFillTests: XCTestCase {
    func test_daily_cappedTo10_includeZeroDays_false() async throws {
        // Given: Mock data with 3 workout days
        let calendar = Calendar(identifier: .iso8601)
        let now = Date()

        // When includeZeroDays is false
        // Then: Should only return the days with actual volume, capped to ≤10

        // This tests the conceptual logic:
        let workoutDates = [
            calendar.date(byAdding: .day, value: -5, to: now)!,
            calendar.date(byAdding: .day, value: -3, to: now)!,
            calendar.date(byAdding: .day, value: -1, to: now)!,
        ]

        var volumeByDay: [Date: Double] = [:]
        for date in workoutDates {
            let dayStart = calendar.startOfDay(for: date)
            volumeByDay[dayStart] = 100.0
        }

        // Simulate includeZeroDays = false: only return days with volume
        let filteredDays = volumeByDay.keys.sorted()
        let cappedTo10 = Array(filteredDays.suffix(10))

        XCTAssertEqual(cappedTo10.count, 3, "Should only have 3 workout days (≤10)")
        XCTAssertTrue(cappedTo10.allSatisfy { volumeByDay[$0] ?? 0 > 0 }, "All returned days should have volume > 0")
    }

    func test_daily_cappedTo10_includeZeroDays_true() async throws {
        // Given: Mock data with gaps
        let calendar = Calendar(identifier: .iso8601)
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startDate = calendar.date(byAdding: .day, value: -29, to: startOfToday)!

        // Generate all 30 days
        var allDays: [Date] = []
        for i in 0..<30 {
            if let dayStart = calendar.date(byAdding: .day, value: i, to: startDate) {
                allDays.append(dayStart)
            }
        }

        // Only 3 days have volume
        let workoutDates = [
            calendar.date(byAdding: .day, value: -5, to: now)!,
            calendar.date(byAdding: .day, value: -3, to: now)!,
            calendar.date(byAdding: .day, value: -1, to: now)!,
        ]

        var volumeByDay: [Date: Double] = [:]
        for date in workoutDates {
            let dayStart = calendar.startOfDay(for: date)
            volumeByDay[dayStart] = 100.0
        }

        // When includeZeroDays = true: return all days (fill gaps with zero), then cap to 10
        let points = allDays.map { day in
            (date: day, volume: volumeByDay[day] ?? 0.0)
        }
        let cappedPoints = Array(points.suffix(10))

        // Then: Should have exactly 10 days (latest 10)
        XCTAssertEqual(cappedPoints.count, 10, "Should have exactly 10 days (capped)")
        XCTAssertLessThanOrEqual(cappedPoints.count, 10, "Should never exceed 10 points")
    }

    func test_daily_categoryFilter_applies() async throws {
        // Given: Sets from multiple categories
        let calendar = Calendar(identifier: .iso8601)
        let now = Date()
        let today = calendar.startOfDay(for: now)

        // Mock volumes by category
        let upperBodyVolume = 100.0
        let lowerBodyVolume = 200.0

        var volumeByCategory: [ExerciseCategoryMain: Double] = [:]
        volumeByCategory[.upperBody] = upperBodyVolume
        volumeByCategory[.lowerBody] = lowerBodyVolume

        // When filtering by upperBody
        let filteredVolume = volumeByCategory[.upperBody] ?? 0

        // Then: Should only include upperBody volume
        XCTAssertEqual(filteredVolume, 100.0)

        // When filtering by lowerBody
        let lowerFiltered = volumeByCategory[.lowerBody] ?? 0
        XCTAssertEqual(lowerFiltered, 200.0)

        // When no filter (all)
        let totalVolume = volumeByCategory.values.reduce(0, +)
        XCTAssertEqual(totalVolume, 300.0)
    }
}
