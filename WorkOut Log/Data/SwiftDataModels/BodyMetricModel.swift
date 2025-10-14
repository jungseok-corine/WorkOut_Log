//
//  BodyMetricModel.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation
import SwiftData

@Model final class BodyMetricModel {
    @Attribute(.unique) var id: String
    var date: Date
    var bodyWeight: Double // kg
    var bodyFatPercent: Double? // %
    var muscleMass: Double? // kg

    init(
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