//
//  FetchBodyMetricsRangeUseCase.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation

public struct FetchBodyMetricsRangeUseCase {
    let repo: BodyMetricRepository

    public init(repo: BodyMetricRepository) {
        self.repo = repo
    }

    public func callAsFunction(start: Date, end: Date) async throws -> [BodyMetric] {
        return try await repo.fetchRange(start: start, end: end)
    }

    // Convenience methods for common time ranges
    public func lastWeek() async throws -> [BodyMetric] {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
        return try await callAsFunction(start: weekAgo, end: now)
    }

    public func lastMonth() async throws -> [BodyMetric] {
        let calendar = Calendar.current
        let now = Date()
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
        return try await callAsFunction(start: monthAgo, end: now)
    }

    public func lastThreeMonths() async throws -> [BodyMetric] {
        let calendar = Calendar.current
        let now = Date()
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now)!
        return try await callAsFunction(start: threeMonthsAgo, end: now)
    }
}