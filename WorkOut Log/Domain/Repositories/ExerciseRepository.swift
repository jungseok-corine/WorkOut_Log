//
//  ExerciseRepository.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

public protocol ExerciseRepository {
    func upsert(_ exercise: Exercise) async throws
    func delete(id: String) async throws
    func search(nameLike: String) async throws -> [Exercise]
    func recent(limit: Int) async throws -> [Exercise]
    func fetchByMain(_ main: ExerciseCategoryMain) async throws -> [Exercise]
    func fetchAll() async throws -> [Exercise]
    func fetch(by id: String) async throws -> Exercise?
    func hasReferencingSets(exerciseID: String) async throws -> Bool
}
