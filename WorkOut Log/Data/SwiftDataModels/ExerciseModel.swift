//
//  ExerciseModel.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation
import SwiftData

@Model final class ExerciseModel {
    @Attribute(.unique) var id: String
    var name: String
    var mainRaw: String // Stores ExerciseCategoryMain.rawValue
    var lastUsedDate: Date? // For recent exercises functionality

    init(id: String, name: String, mainRaw: String, lastUsedDate: Date? = nil) {
        self.id = id
        self.name = name
        self.mainRaw = mainRaw
        self.lastUsedDate = lastUsedDate
    }
}
