//
//  Exercise.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

public enum ExerciseCategory: String, Sendable, CaseIterable, Codable {
    case chest
    case back
    case shoulders
    case biceps
    case triceps
    case legs
    case fullBody

    public var displayName: String {
        switch self {
        case .chest: return "Chest"
        case .back: return "Back"
        case .shoulders: return "Shoulders"
        case .biceps: return "Biceps"
        case .triceps: return "Triceps"
        case .legs: return "Legs"
        case .fullBody: return "Full Body"
        }
    }
}

public struct Exercise: Sendable, Equatable, Identifiable {
    public let id: String
    public var name: String
    public var category: ExerciseCategory

    public init(id: String, name: String, category: ExerciseCategory) {
        self.id = id
        self.name = name
        self.category = category
    }
}
