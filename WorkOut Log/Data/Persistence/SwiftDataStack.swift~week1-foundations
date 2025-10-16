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
        let schema = Schema([ExerciseModel.self, WorkoutSessionModel.self, SetRecordModel.self])
        return try ModelContainer(for: schema)
    }
}
