//
//  ComputePRUseCase.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation

public struct PersonalRecord: Sendable, Equatable {
    public let exerciseID: String
    public let maxWeight: Double
    public let estimatedOneRM: Double // Epley formula
    public let achievedDate: Date

    public init(exerciseID: String, maxWeight: Double, estimatedOneRM: Double, achievedDate: Date) {
        self.exerciseID = exerciseID
        self.maxWeight = maxWeight
        self.estimatedOneRM = estimatedOneRM
        self.achievedDate = achievedDate
    }
}

public struct ComputePRUseCase {
    let sessionRepo: SessionRepository

    public init(sessionRepo: SessionRepository) {
        self.sessionRepo = sessionRepo
    }

    public func callAsFunction(exerciseID: String) async throws -> PersonalRecord? {
        // Get all sessions and find the max weight for this exercise
        let allSessions = try await sessionRepo.fetchRange(
            start: Date.distantPast,
            end: Date.distantFuture
        )

        var maxWeight: Double = 0
        var maxReps: Int = 0
        var achievedDate: Date = Date.distantPast

        for session in allSessions {
            let sets = try await sessionRepo.fetchSets(sessionID: session.id)

            for set in sets where set.exerciseID == exerciseID {
                if set.weight > maxWeight {
                    maxWeight = set.weight
                    maxReps = set.reps
                    achievedDate = session.date
                }
            }
        }

        guard maxWeight > 0 else { return nil }

        // Calculate estimated 1RM using Epley formula: weight × (1 + reps/30)
        let estimatedOneRM = maxWeight * (1 + Double(maxReps) / 30.0)

        return PersonalRecord(
            exerciseID: exerciseID,
            maxWeight: maxWeight,
            estimatedOneRM: estimatedOneRM,
            achievedDate: achievedDate
        )
    }

    public func isNewPR(exerciseID: String, weight: Double, reps: Int) async throws -> Bool {
        guard let currentPR = try await callAsFunction(exerciseID: exerciseID) else {
            return true // First time doing this exercise
        }

        // Check if this weight is higher than current PR
        if weight > currentPR.maxWeight {
            return true
        }

        // Check if estimated 1RM is higher
        let newEstimatedOneRM = weight * (1 + Double(reps) / 30.0)
        return newEstimatedOneRM > currentPR.estimatedOneRM
    }
}