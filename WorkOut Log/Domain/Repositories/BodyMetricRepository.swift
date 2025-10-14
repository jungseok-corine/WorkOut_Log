//
//  BodyMetricRepository.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation

public protocol BodyMetricRepository {
    func create(_ metric: BodyMetric) async throws
    func update(_ metric: BodyMetric) async throws
    func delete(id: String) async throws
    func fetch(by id: String) async throws -> BodyMetric?
    func fetchRange(start: Date, end: Date) async throws -> [BodyMetric]
    func latest() async throws -> BodyMetric?
}