//
//  ExerciseRepositoryImpl.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation
import SwiftData

final class ExerciseRepositoryImpl: ExerciseRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func upsert(_ exercise: Exercise) async throws {
        // Extract values to avoid macro capture
        let exerciseID = exercise.id
        let exerciseName = exercise.name
        let exerciseMainRaw = exercise.main.rawValue

        let existingPredicate = #Predicate<ExerciseModel> { model in
            model.id == exerciseID
        }
        var descriptor = FetchDescriptor<ExerciseModel>(predicate: existingPredicate)
        descriptor.fetchLimit = 1

        if let existing = try context.fetch(descriptor).first {
            // Update existing
            existing.name = exerciseName
            existing.mainRaw = exerciseMainRaw
            existing.lastUsedDate = Date() // Update last used date
        } else {
            // Create new
            let model = ExerciseModel.fromDomain(exercise)
            model.lastUsedDate = Date()
            context.insert(model)
        }

        try context.save()
    }

    func delete(id: String) async throws {
        // Check for referencing sets first
        if try await hasReferencingSets(exerciseID: id) {
            throw NSError(
                domain: "ExerciseRepository",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Cannot delete exercise with existing sets"]
            )
        }

        let exerciseID = id
        let predicate = #Predicate<ExerciseModel> { model in
            model.id == exerciseID
        }
        var descriptor = FetchDescriptor<ExerciseModel>(predicate: predicate)
        descriptor.fetchLimit = 1

        if let exercise = try context.fetch(descriptor).first {
            context.delete(exercise)
            try context.save()
        }
    }

    func hasReferencingSets(exerciseID: String) async throws -> Bool {
        let exID = exerciseID
        let predicate = #Predicate<SetRecordModel> { model in
            model.exerciseID == exID
        }
        var descriptor = FetchDescriptor<SetRecordModel>(predicate: predicate)
        descriptor.fetchLimit = 1

        return try !context.fetch(descriptor).isEmpty
    }

    func search(nameLike: String) async throws -> [Exercise] {
        let query = nameLike.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return try await fetchAll()
        }

        // Fetch all exercises sorted by name
        // Note: Cannot use .localizedLowercase in SwiftData KeyPath predicates
        // (SwiftData only supports stored properties, not value-type member chaining)
        // Instead, fetch all and filter client-side for case-insensitive search
        let sort = [SortDescriptor(\ExerciseModel.name, order: .forward)]
        var descriptor = FetchDescriptor<ExerciseModel>(sortBy: sort)
        descriptor.fetchLimit = 200 // Prevent unbounded growth

        // Apply case-insensitive filter in-memory
        return try context.fetch(descriptor)
            .filter { $0.name.localizedStandardContains(query) }
            .map { $0.toDomain() }
    }

    func recent(limit: Int) async throws -> [Exercise] {
        let predicate = #Predicate<ExerciseModel> { model in
            model.lastUsedDate != nil
        }
        let sort = [SortDescriptor(\ExerciseModel.lastUsedDate, order: .reverse)]
        var descriptor = FetchDescriptor<ExerciseModel>(predicate: predicate, sortBy: sort)
        descriptor.fetchLimit = limit

        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func fetchByMain(_ main: ExerciseCategoryMain) async throws -> [Exercise] {
        let mainRaw = main.rawValue
        let predicate = #Predicate<ExerciseModel> { model in
            model.mainRaw == mainRaw
        }
        let sort = [SortDescriptor(\ExerciseModel.name, order: .forward)]
        let descriptor = FetchDescriptor<ExerciseModel>(predicate: predicate, sortBy: sort)

        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func fetchAll() async throws -> [Exercise] {
        let sort = [SortDescriptor(\ExerciseModel.name, order: .forward)]
        let descriptor = FetchDescriptor<ExerciseModel>(sortBy: sort)

        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func fetch(by id: String) async throws -> Exercise? {
        let exerciseID = id
        let predicate = #Predicate<ExerciseModel> { model in
            model.id == exerciseID
        }
        var descriptor = FetchDescriptor<ExerciseModel>(predicate: predicate)
        descriptor.fetchLimit = 1

        return try context.fetch(descriptor).first?.toDomain()
    }
}