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

    public func callAsFunction(query: String, main: ExerciseCategoryMain? = nil) async throws -> [Exercise] {
        let searchResults = try await repo.search(nameLike: query)

        if let main = main {
            return searchResults.filter { $0.main == main }
        }

        return searchResults
    }
}