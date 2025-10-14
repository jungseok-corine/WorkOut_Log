//
//  ExerciseRepository.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation

public protocol ExerciseRepository {
    func upsert(_ exercise: Exercise) async throws
    func search(nameLike: String) async throws -> [Exercise]
    func fetchAll() async throws -> [Exercise]
}
