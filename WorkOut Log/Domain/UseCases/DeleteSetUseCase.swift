//
//  DeleteSetUseCase.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation

public struct DeleteSetUseCase {
    let repo: SessionRepository

    public init(repo: SessionRepository) {
        self.repo = repo
    }

    public func callAsFunction(setID: String) async throws {
        try await repo.deleteSet(id: setID)
    }
}