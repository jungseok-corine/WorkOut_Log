//
//  DeleteSessionUseCase.swift
//  WorkOut Log
//
//  Created by Claude on 15/10/2025.
//

import Foundation

public struct DeleteSessionUseCase {
    let repo: SessionRepository

    public init(repo: SessionRepository) {
        self.repo = repo
    }

    public func callAsFunction(sessionID: String) async throws {
        try await repo.delete(sessionID: sessionID)
    }
}
