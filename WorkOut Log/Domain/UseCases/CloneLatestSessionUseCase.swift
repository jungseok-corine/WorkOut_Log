//
//  CloneLatestSessionUseCase.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation

public struct CloneLatestSessionUseCase {
    let repo: SessionRepository
    public init(repo: SessionRepository) { self.repo = repo }
    public func callAsFunction(newDate: Date) async throws -> WorkoutSession? {
        guard let latest = try await repo.latest() else { return nil }
        let cloned = WorkoutSession(id: UUID().uuidString, date: Calendar.current.startOfDay(for: newDate), note: latest.note)
        try await repo.create(session: cloned)
        let sets = try await repo.fetchSets(sessionID: latest.id)
        for (idx, s) in sets.enumerated() {
            let ns = SetRecord(id: UUID().uuidString, sessionID: cloned.id, exerciseID: s.exerciseID, weight: s.weight, reps: s.reps, order: idx)
            try await repo.add(set: ns)
        }
        return cloned
    }
}
