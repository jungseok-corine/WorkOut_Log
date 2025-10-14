//
//  CreateBodyMetricUseCase.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation

public struct CreateBodyMetricUseCase {
    let repo: BodyMetricRepository

    public init(repo: BodyMetricRepository) {
        self.repo = repo
    }

    public func callAsFunction(
        date: Date,
        bodyWeight: Double,
        bodyFatPercent: Double? = nil,
        muscleMass: Double? = nil
    ) async throws -> BodyMetric {
        let metric = BodyMetric(
            id: UUID().uuidString,
            date: date,
            bodyWeight: bodyWeight,
            bodyFatPercent: bodyFatPercent,
            muscleMass: muscleMass
        )

        try await repo.create(metric)
        return metric
    }
}