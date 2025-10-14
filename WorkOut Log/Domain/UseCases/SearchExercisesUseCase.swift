//
//  SearchExercisesUseCase.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

public struct SearchExercisesUseCase {
    let repo: ExerciseRepository

    public init(repo: ExerciseRepository) {
        self.repo = repo
    }

    public func callAsFunction(query: String, category: ExerciseCategory? = nil) async throws -> [Exercise] {
        let searchResults = try await repo.search(nameLike: query)

        if let category = category {
            return searchResults.filter { $0.category == category }
        }

        return searchResults
    }
}