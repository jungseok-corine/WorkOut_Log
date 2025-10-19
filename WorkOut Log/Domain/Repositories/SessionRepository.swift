//
//  SessionRepository.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation

public protocol SessionRepository {
    func create(session: WorkoutSession) async throws
    func update(session: WorkoutSession) async throws
    func delete(sessionID: String) async throws
    func fetch(by id: String) async throws -> WorkoutSession?
    func fetchAll() async throws -> [WorkoutSession]
    func fetchRange(start: Date, end: Date) async throws -> [WorkoutSession]
    func latest() async throws -> WorkoutSession?
    // Sets
    func add(set: SetRecord) async throws
    func update(set: SetRecord) async throws
    func deleteSet(id: String) async throws
    func fetchSets(sessionID: String) async throws -> [SetRecord]
}
