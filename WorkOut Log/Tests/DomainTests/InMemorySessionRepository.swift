//
//  InMemorySessionRepository.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

@testable import workout_log
import Foundation

final class InMemorySessionRepository: SessionRepository {
    var sessions: [String:WorkoutSession] = [:]
    var sets: [String:[SetRecord]] = [:] // sessionID -> sets

    func create(session: WorkoutSession) async throws { sessions[session.id] = session }
    func update(session: WorkoutSession) async throws { sessions[session.id] = session }
    func delete(sessionID: String) async throws { sessions.removeValue(forKey: sessionID); sets[sessionID] = [] }
    func fetch(by id: String) async throws -> WorkoutSession? { sessions[id] }
    func fetchRange(start: Date, end: Date) async throws -> [WorkoutSession] {
        sessions.values.filter { $0.date >= start && $0.date < end }.sorted { $0.date > $1.date }
    }
    func latest() async throws -> WorkoutSession? {
        sessions.values.sorted { $0.date > $1.date }.first
    }
    func add(set: SetRecord) async throws { sets[set.sessionID, default: []].append(set) }
    func update(set: SetRecord) async throws {
        guard var arr = sets[set.sessionID] else { return }
        if let idx = arr.firstIndex(where: {$0.id == set.id}) { arr[idx] = set; sets[set.sessionID] = arr }
    }
    func deleteSet(id: String) async throws {
        for key in sets.keys { sets[key]?.removeAll { $0.id == id } }
    }
    func fetchSets(sessionID: String) async throws -> [SetRecord] {
        sets[sessionID, default: []].sorted{ $0.order < $1.order }
    }
}
