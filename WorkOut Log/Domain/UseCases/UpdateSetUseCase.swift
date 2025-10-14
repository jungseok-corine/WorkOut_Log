//
//  UpdateSetUseCase.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation

public struct UpdateSetUseCase {
    let repo: SessionRepository

    public init(repo: SessionRepository) {
        self.repo = repo
    }

    public func callAsFunction(set: SetRecord, newWeight: Double, newReps: Int) async throws -> SetRecord {
        let updatedSet = SetRecord(
            id: set.id,
            sessionID: set.sessionID,
            exerciseID: set.exerciseID,
            weight: newWeight,
            reps: newReps,
            order: set.order
        )

        try await repo.update(set: updatedSet)
        return updatedSet
    }
}