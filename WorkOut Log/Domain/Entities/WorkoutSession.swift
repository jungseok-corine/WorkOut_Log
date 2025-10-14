//
//  WorkoutSession.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation

public struct WorkoutSession: Sendable, Equatable, Identifiable {
    public let id: String
    public var date: Date
    public var note: String?
    public init(id: String, date: Date, note: String? = nil) {
        self.id = id; self.date = date; self.note = note
    }
}
