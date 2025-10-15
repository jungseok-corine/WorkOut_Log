//
//  UpsertExerciseUseCase.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation

public struct UpsertExerciseUseCase {
    let repo: ExerciseRepository

    public init(repo: ExerciseRepository) {
        self.repo = repo
    }

    public func callAsFunction(name: String, main: ExerciseCategoryMain, upper: ExerciseCategoryUpper? = nil) async throws -> Exercise {
        let exercise = Exercise(
            id: UUID().uuidString,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            main: main,
            upper: upper
        )
        try await repo.upsert(exercise)
        return exercise
    }

    public func callAsFunction(_ exercise: Exercise) async throws {
        try await repo.upsert(exercise)
    }
}