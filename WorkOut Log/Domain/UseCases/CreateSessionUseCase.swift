//
//  CreateSessionUseCase.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation

public struct CreateSessionUseCase {
    let repo: SessionRepository
    public init(repo: SessionRepository) { self.repo = repo }
    public func callAsFunction(date: Date = .now, note: String? = nil) async throws -> WorkoutSession {
        let s = WorkoutSession(id: UUID().uuidString, date: Calendar.current.startOfDay(for: date), note: note)
        try await repo.create(session: s)
        return s
    }
}
