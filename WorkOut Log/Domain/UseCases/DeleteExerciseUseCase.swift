//
//  DeleteExerciseUseCase.swift
//  WorkOut Log
//
//  Created by Claude on 16/10/2025.
//

import Foundation

public struct DeleteExerciseUseCase {
    let repo: ExerciseRepository

    public init(repo: ExerciseRepository) {
        self.repo = repo
    }

    public func callAsFunction(id: String) async throws {
        try await repo.delete(id: id)
    }
}
