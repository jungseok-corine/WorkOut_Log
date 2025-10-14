//
//  BodyMetric.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation

public struct BodyMetric: Sendable, Equatable, Identifiable {
    public let id: String
    public var date: Date
    public var bodyWeight: Double // kg
    public var bodyFatPercent: Double? // %
    public var muscleMass: Double? // kg

    public init(
        id: String,
        date: Date,
        bodyWeight: Double,
        bodyFatPercent: Double? = nil,
        muscleMass: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.bodyWeight = bodyWeight
        self.bodyFatPercent = bodyFatPercent
        self.muscleMass = muscleMass
    }
}