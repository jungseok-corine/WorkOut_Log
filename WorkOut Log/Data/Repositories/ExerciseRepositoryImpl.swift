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
        // Check if exercise already exists
        let exerciseID = exercise.id
        let existingPredicate = #Predicate<ExerciseModel> { $0.id == exerciseID }
        var descriptor = FetchDescriptor<ExerciseModel>(predicate: existingPredicate)
        descriptor.fetchLimit = 1

        if let existing = try context.fetch(descriptor).first {
            // Update existing
            existing.name = exercise.name
            existing.category = exercise.category
            existing.lastUsedDate = Date() // Update last used date
        } else {
            // Create new
            let model = ExerciseModel.fromDomain(exercise)
            model.lastUsedDate = Date()
            context.insert(model)
        }

        try context.save()
    }

    func search(nameLike: String) async throws -> [Exercise] {
        let query = nameLike.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else {
            return try await fetchAll()
        }

        let searchQuery = query
        let predicate = #Predicate<ExerciseModel> { model in
            model.name.localizedLowercase.contains(searchQuery)
        }

        let sort = [SortDescriptor(\ExerciseModel.name, order: .forward)]
        let descriptor = FetchDescriptor<ExerciseModel>(predicate: predicate, sortBy: sort)

        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func recent(limit: Int) async throws -> [Exercise] {
        let predicate = #Predicate<ExerciseModel> { $0.lastUsedDate != nil }
        let sort = [SortDescriptor(\ExerciseModel.lastUsedDate, order: .reverse)]
        var descriptor = FetchDescriptor<ExerciseModel>(predicate: predicate, sortBy: sort)
        descriptor.fetchLimit = limit

        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func fetchByCategory(_ category: ExerciseCategory) async throws -> [Exercise] {
        let categoryRaw = category.rawValue
        let predicate = #Predicate<ExerciseModel> { $0.categoryRaw == categoryRaw }
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
        let predicate = #Predicate<ExerciseModel> { $0.id == exerciseID }
        var descriptor = FetchDescriptor<ExerciseModel>(predicate: predicate)
        descriptor.fetchLimit = 1

        return try context.fetch(descriptor).first?.toDomain()
    }
}