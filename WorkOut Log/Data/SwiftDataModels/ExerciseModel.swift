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
    var bodyPart: String?
    init(id: String, name: String, bodyPart: String? = nil) {
        self.id = id; self.name = name; self.bodyPart = bodyPart
    }
}
