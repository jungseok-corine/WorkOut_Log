//
//  ModelMappers.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation
import SwiftData

extension ExerciseModel {
    func toDomain() -> Exercise {
        Exercise(
            id: id,
            name: name,
            main: ExerciseCategoryMain(rawValue: mainRaw) ?? .fullBody,
            upper: upperRaw.flatMap { ExerciseCategoryUpper(rawValue: $0) }
        )
    }

    static func fromDomain(_ exercise: Exercise) -> ExerciseModel {
        ExerciseModel(
            id: exercise.id,
            name: exercise.name,
            mainRaw: exercise.main.rawValue,
            upperRaw: exercise.upper?.rawValue
        )
    }
}

extension WorkoutSessionModel {
    func toDomain() -> WorkoutSession {
        WorkoutSession(id: id, date: date, note: note)
    }
}

extension SetRecordModel {
    func toDomain() -> SetRecord {
        SetRecord(
            id: id,
            sessionID: sessionID,
            exerciseID: exerciseID,
            weight: weight,
            reps: reps,
            order: order
        )
    }
}

extension BodyMetricModel {
    func toDomain() -> BodyMetric {
        BodyMetric(
            id: id,
            date: date,
            bodyWeight: bodyWeight,
            bodyFatPercent: bodyFatPercent,
            muscleMass: muscleMass
        )
    }

    static func fromDomain(_ metric: BodyMetric) -> BodyMetricModel {
        BodyMetricModel(
            id: metric.id,
            date: metric.date,
            bodyWeight: metric.bodyWeight,
            bodyFatPercent: metric.bodyFatPercent,
            muscleMass: metric.muscleMass
        )
    }
}
