//
//  ComputeVolumeTrendUseCase.swift
//  WorkOut Log
//
//  Created by Claude on 15/10/2025.
//

import Foundation

public enum TrendScope {
    case weekly
    case monthly
}

public struct VolumeTrendPoint: Sendable, Equatable, Identifiable {
    public let id = UUID()
    public let date: Date
    public let volume: Double
    public let periodLabel: String

    public init(date: Date, volume: Double, periodLabel: String) {
        self.date = date
        self.volume = volume
        self.periodLabel = periodLabel
    }
}

public struct ComputeVolumeTrendUseCase {
    let sessionRepo: SessionRepository
    let exerciseRepo: ExerciseRepository

    public init(sessionRepo: SessionRepository, exerciseRepo: ExerciseRepository) {
        self.sessionRepo = sessionRepo
        self.exerciseRepo = exerciseRepo
    }

    public func callAsFunction(scope: TrendScope, categoryFilter: ExerciseCategoryMain? = nil) async throws -> [VolumeTrendPoint] {
        let calendar = Calendar(identifier: .iso8601)
        let now = Date()

        // Determine date range and periods
        let (startDate, periods) = calculatePeriods(scope: scope, calendar: calendar, now: now)

        // Fetch all sessions in range
        let endDate = calendar.date(byAdding: .day, value: 1, to: now)!
        let sessions = try await sessionRepo.fetchRange(start: startDate, end: endDate)

        // Build volume map by period
        var volumeByPeriod: [Date: Double] = [:]

        for session in sessions {
            let periodStart = getPeriodStart(for: session.date, scope: scope, calendar: calendar)
            let sets = try await sessionRepo.fetchSets(sessionID: session.id)

            for set in sets {
                // Apply category filter
                if let filter = categoryFilter {
                    if let exercise = try await exerciseRepo.fetch(by: set.exerciseID) {
                        if exercise.main != filter {
                            continue
                        }
                    }
                }

                volumeByPeriod[periodStart, default: 0] += set.volume
            }
        }

        // Generate trend points for all periods (including zeros)
        let formatter = DateFormatter()
        formatter.dateFormat = scope == .weekly ? "MMM dd" : "MMM"

        return periods.map { periodStart in
            VolumeTrendPoint(
                date: periodStart,
                volume: volumeByPeriod[periodStart] ?? 0,
                periodLabel: formatter.string(from: periodStart)
            )
        }
    }

    private func calculatePeriods(scope: TrendScope, calendar: Calendar, now: Date) -> (Date, [Date]) {
        switch scope {
        case .weekly:
            // Last 8 weeks
            let startOfThisWeek = calendar.dateInterval(of: .weekOfYear, for: now)!.start
            let startDate = calendar.date(byAdding: .weekOfYear, value: -7, to: startOfThisWeek)!

            var periods: [Date] = []
            for i in 0..<8 {
                if let weekStart = calendar.date(byAdding: .weekOfYear, value: i, to: startDate) {
                    periods.append(weekStart)
                }
            }
            return (startDate, periods)

        case .monthly:
            // Last 6 months
            let startOfThisMonth = calendar.dateInterval(of: .month, for: now)!.start
            let startDate = calendar.date(byAdding: .month, value: -5, to: startOfThisMonth)!

            var periods: [Date] = []
            for i in 0..<6 {
                if let monthStart = calendar.date(byAdding: .month, value: i, to: startDate) {
                    periods.append(monthStart)
                }
            }
            return (startDate, periods)
        }
    }

    private func getPeriodStart(for date: Date, scope: TrendScope, calendar: Calendar) -> Date {
        switch scope {
        case .weekly:
            return calendar.dateInterval(of: .weekOfYear, for: date)!.start
        case .monthly:
            return calendar.dateInterval(of: .month, for: date)!.start
        }
    }
}
