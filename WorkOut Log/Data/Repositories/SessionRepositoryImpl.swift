//
//  SessionRepositoryImpl.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

// Data/Repositories/SessionRepositoryImpl.swift
import Foundation
import SwiftData

final class SessionRepositoryImpl: SessionRepository {
    private let context: ModelContext
    init(context: ModelContext) { self.context = context }

    // MARK: Session
    func create(session: WorkoutSession) async throws {
        context.insert(WorkoutSessionModel(id: session.id, date: session.date, note: session.note))
        try context.save()
    }

    func update(session: WorkoutSession) async throws {
        if let m = try fetchSessionModel(id: session.id) {
            m.date = session.date
            m.note = session.note
            try context.save()
        }
    }

    func delete(sessionID: String) async throws {
        if let sessionModel = try fetchSessionModel(id: sessionID) {
            // @Relationship(deleteRule: .cascade)로 인해 관련 sets도 자동 삭제됨
            context.delete(sessionModel)
            try context.save()
        }
    }

    func fetch(by id: String) async throws -> WorkoutSession? {
        try fetchSessionModel(id: id)?.toDomain()
    }

    func fetchAll() async throws -> [WorkoutSession] {
        // Sort by date descending (most recent first), with id ascending as stable tie-breaker
        let sort = [
            SortDescriptor(\WorkoutSessionModel.date, order: .reverse),
            SortDescriptor(\WorkoutSessionModel.id, order: .forward)
        ]
        let d = FetchDescriptor<WorkoutSessionModel>(sortBy: sort)
        return try context.fetch(d).map { $0.toDomain() }
    }

    func fetchRange(start: Date, end: Date) async throws -> [WorkoutSession] {
        let predicate = #Predicate<WorkoutSessionModel> { $0.date >= start && $0.date < end }
        // Sort by date descending (most recent first), with id ascending as stable tie-breaker
        let sort = [
            SortDescriptor(\WorkoutSessionModel.date, order: .reverse),
            SortDescriptor(\WorkoutSessionModel.id, order: .forward)
        ]
        let d = FetchDescriptor<WorkoutSessionModel>(predicate: predicate, sortBy: sort)
        return try context.fetch(d).map { $0.toDomain() }
    }

    func latest() async throws -> WorkoutSession? {
        // Sort by date descending, with id ascending as stable tie-breaker
        let sort = [
            SortDescriptor(\WorkoutSessionModel.date, order: .reverse),
            SortDescriptor(\WorkoutSessionModel.id, order: .forward)
        ]
        var d = FetchDescriptor<WorkoutSessionModel>(sortBy: sort)
        // 일부 Xcode 버전에서 init(fetchLimit:) 미지원 → 프로퍼티로 설정
        d.fetchLimit = 1
        return try context.fetch(d).first?.toDomain()
    }

    // MARK: Sets
    func add(set: SetRecord) async throws {
        let setModel = SetRecordModel(id: set.id, sessionID: set.sessionID, exerciseID: set.exerciseID, weight: set.weight, reps: set.reps, order: set.order)

        // 관계 설정
        if let session = try fetchSessionModel(id: set.sessionID) {
            session.sets.append(setModel)
        }

        context.insert(setModel)
        try context.save()
    }

    func update(set: SetRecord) async throws {
        if let m = try fetchSetModel(id: set.id) {
            m.weight = set.weight
            m.reps = set.reps
            m.order = set.order
            try context.save()
        }
    }

    func deleteSet(id: String) async throws {
        if let setModel = try fetchSetModel(id: id) {
            // SwiftData가 관계를 자동으로 관리하므로 직접 제거할 필요 없음
            context.delete(setModel)
            try context.save()
        }
    }

    func fetchSets(sessionID: String) async throws -> [SetRecord] {
        // 관계를 활용하여 더 효율적으로 조회
        if let session = try fetchSessionModel(id: sessionID) {
            return session.sets.sorted { $0.order < $1.order }.map { $0.toDomain() }
        } else {
            // 관계가 설정되지 않은 경우를 위한 fallback
            let predicate = #Predicate<SetRecordModel> { $0.sessionID == sessionID }
            let sort = [SortDescriptor(\SetRecordModel.order, order: .forward)]
            let d = FetchDescriptor<SetRecordModel>(predicate: predicate, sortBy: sort)
            return try context.fetch(d).map { $0.toDomain() }
        }
    }

    // MARK: helpers
    private func fetchSessionModel(id: String) throws -> WorkoutSessionModel? {
        let predicate = #Predicate<WorkoutSessionModel> { $0.id == id }
        var d = FetchDescriptor<WorkoutSessionModel>(predicate: predicate)
        d.fetchLimit = 1
        return try context.fetch(d).first
    }

    private func fetchSetModel(id: String) throws -> SetRecordModel? {
        let predicate = #Predicate<SetRecordModel> { $0.id == id }
        var d = FetchDescriptor<SetRecordModel>(predicate: predicate)
        d.fetchLimit = 1
        return try context.fetch(d).first
    }
}
