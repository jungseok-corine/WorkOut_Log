//
//  SetRecordModel.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import SwiftData

@Model final class SetRecordModel {
    @Attribute(.unique) var id: String
    var sessionID: String
    var exerciseID: String
    var weight: Double
    var reps: Int
    var order: Int

    @Relationship(inverse: \WorkoutSessionModel.sets) var session: WorkoutSessionModel?

    init(id: String, sessionID: String, exerciseID: String, weight: Double, reps: Int, order: Int) {
        self.id = id; self.sessionID = sessionID; self.exerciseID = exerciseID
        self.weight = weight; self.reps = reps; self.order = order
    }
}
