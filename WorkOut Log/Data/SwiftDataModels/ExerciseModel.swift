//
//  ExerciseModel.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import SwiftData

@Model final class ExerciseModel {
    @Attribute(.unique) var id: String
    var name: String
    var categoryRaw: String // v2: Stores ExerciseCategory.rawValue
    var lastUsedDate: Date? // For recent exercises functionality

    init(id: String, name: String, categoryRaw: String, lastUsedDate: Date? = nil) {
        self.id = id
        self.name = name
        self.categoryRaw = categoryRaw
        self.lastUsedDate = lastUsedDate
    }

    // Convenience computed property
    var category: ExerciseCategory {
        get { ExerciseCategory(rawValue: categoryRaw) ?? .fullBody }
        set { categoryRaw = newValue.rawValue }
    }
}
