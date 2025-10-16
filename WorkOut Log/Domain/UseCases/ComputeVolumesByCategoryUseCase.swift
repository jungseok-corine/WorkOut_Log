//
//  ComputeVolumesByCategoryUseCase.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation

public struct CategoryVolume: Sendable, Equatable {
    public let category: ExerciseCategoryMain
    public let totalVolume: Double

    public init(category: ExerciseCategoryMain, totalVolume: Double) {
        self.category = category
        self.totalVolume = totalVolume
    }
}

public struct ComputeVolumesByCategoryUseCase {
    let sessionRepo: SessionRepository
    let exerciseRepo: ExerciseRepository

    public init(sessionRepo: SessionRepository, exerciseRepo: ExerciseRepository) {
        self.sessionRepo = sessionRepo
        self.exerciseRepo = exerciseRepo
    }

    public func callAsFunction(start: Date, end: Date) async throws -> [CategoryVolume] {
        // Get all sessions in the date range
        let sessions = try await sessionRepo.fetchRange(start: start, end: end)

        // Group volumes by main category
        var categoryVolumes: [ExerciseCategoryMain: Double] = [:]

        for session in sessions {
            let sets = try await sessionRepo.fetchSets(sessionID: session.id)

            for set in sets {
                // Get exercise to determine category
                if let exercise = try await exerciseRepo.fetch(by: set.exerciseID) {
                    let volume = set.volume
                    categoryVolumes[exercise.main, default: 0] += volume
                }
            }
        }

        // Convert to CategoryVolume array
        return categoryVolumes.map { CategoryVolume(category: $0.key, totalVolume: $0.value) }
            .sorted { $0.totalVolume > $1.totalVolume }
    }

    // ISO Week helpers
    public func currentWeekRange() -> (start: Date, end: Date) {
        let calendar = Calendar(identifier: .iso8601)
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)!.start
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        return (start: startOfWeek, end: endOfWeek)
    }

    public func currentMonthRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)!.start
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        return (start: startOfMonth, end: endOfMonth)
    }
}