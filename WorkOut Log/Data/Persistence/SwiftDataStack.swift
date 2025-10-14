//
//  SwiftDataStack.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation
import SwiftData

enum SwiftDataStack {
    static func container() throws -> ModelContainer {
        // v3 Schema includes all models
        let schema = Schema([
            ExerciseModel.self,
            WorkoutSessionModel.self,
            SetRecordModel.self,
            BodyMetricModel.self
        ])

        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        return try ModelContainer(for: schema, configurations: [config])
    }
}

// MARK: - Migration Notes
/*
 Migration Plan:

 v1 → v2:
 - ExerciseModel: Replace `bodyPart: String?` with `categoryRaw: String` + `lastUsedDate: Date?`
 - For small dev datasets, recommend clearing data and re-creating
 - For production: Would need custom migration mapping bodyPart → category

 v2 → v3:
 - Add BodyMetricModel (new table, no migration needed)
 - No changes to existing models

 Current Status: Using v3 schema directly (suitable for development)
 */
