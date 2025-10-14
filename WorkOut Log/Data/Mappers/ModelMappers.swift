//
//  ModelMappers.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation
import SwiftData

extension ExerciseModel {
    func toDomain() -> Exercise { .init(id: id, name: name, bodyPart: bodyPart) }
}
extension WorkoutSessionModel {
    func toDomain() -> WorkoutSession { .init(id: id, date: date, note: note) }
}
extension SetRecordModel {
    func toDomain() -> SetRecord { .init(id: id, sessionID: sessionID, exerciseID: exerciseID, weight: weight, reps: reps, order: order) }
}
