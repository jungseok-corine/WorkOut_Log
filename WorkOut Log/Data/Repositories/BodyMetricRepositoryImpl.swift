//
//  BodyMetricRepositoryImpl.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation
import SwiftData

final class BodyMetricRepositoryImpl: BodyMetricRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func create(_ metric: BodyMetric) async throws {
        let model = BodyMetricModel.fromDomain(metric)
        context.insert(model)
        try context.save()
    }

    func update(_ metric: BodyMetric) async throws {
        let predicate = #Predicate<BodyMetricModel> { $0.id == metric.id }
        var descriptor = FetchDescriptor<BodyMetricModel>(predicate: predicate)
        descriptor.fetchLimit = 1

        if let existing = try context.fetch(descriptor).first {
            existing.date = metric.date
            existing.bodyWeight = metric.bodyWeight
            existing.bodyFatPercent = metric.bodyFatPercent
            existing.muscleMass = metric.muscleMass
            try context.save()
        }
    }

    func delete(id: String) async throws {
        let predicate = #Predicate<BodyMetricModel> { $0.id == id }
        var descriptor = FetchDescriptor<BodyMetricModel>(predicate: predicate)
        descriptor.fetchLimit = 1

        if let model = try context.fetch(descriptor).first {
            context.delete(model)
            try context.save()
        }
    }

    func fetch(by id: String) async throws -> BodyMetric? {
        let predicate = #Predicate<BodyMetricModel> { $0.id == id }
        var descriptor = FetchDescriptor<BodyMetricModel>(predicate: predicate)
        descriptor.fetchLimit = 1

        return try context.fetch(descriptor).first?.toDomain()
    }

    func fetchRange(start: Date, end: Date) async throws -> [BodyMetric] {
        let predicate = #Predicate<BodyMetricModel> { $0.date >= start && $0.date < end }
        let sort = [SortDescriptor(\BodyMetricModel.date, order: .forward)]
        let descriptor = FetchDescriptor<BodyMetricModel>(predicate: predicate, sortBy: sort)

        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func latest() async throws -> BodyMetric? {
        let sort = [SortDescriptor(\BodyMetricModel.date, order: .reverse)]
        var descriptor = FetchDescriptor<BodyMetricModel>(sortBy: sort)
        descriptor.fetchLimit = 1

        return try context.fetch(descriptor).first?.toDomain()
    }
}