//
//  WorkoutSessionModel.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation
import SwiftData

@Model final class WorkoutSessionModel {
    @Attribute(.unique) var id: String
    var date: Date
    var note: String?
    @Relationship(deleteRule: .cascade) var sets: [SetRecordModel] = []
    init(id: String, date: Date, note: String? = nil) {
        self.id = id; self.date = date; self.note = note
    }
}
