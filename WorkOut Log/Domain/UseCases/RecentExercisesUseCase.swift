//
//  RecentExercisesUseCase.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

public struct RecentExercisesUseCase {
    let repo: ExerciseRepository

    public init(repo: ExerciseRepository) {
        self.repo = repo
    }

    public func callAsFunction(limit: Int = 10) async throws -> [Exercise] {
        return try await repo.recent(limit: limit)
    }
}