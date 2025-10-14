//
//  AddSetUseCase.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation

public struct AddSetUseCase {
    let repo: SessionRepository
    public init(repo: SessionRepository) { self.repo = repo }
    public func callAsFunction(sessionID: String, exerciseID: String, weight: Double, reps: Int, order: Int) async throws -> SetRecord {
        let set = SetRecord(id: UUID().uuidString, sessionID: sessionID, exerciseID: exerciseID, weight: weight, reps: reps, order: order)
        try await repo.add(set: set)
        return set
    }
}
