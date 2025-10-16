//
//  Exercise.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

// Main category (대분류)
public enum ExerciseCategoryMain: String, Sendable, CaseIterable, Codable {
    case lowerBody
    case upperBody
    case cardio
    case fullBody

    public var displayName: String {
        switch self {
        case .lowerBody: return "Lower Body"
        case .upperBody: return "Upper Body"
        case .cardio: return "Cardio"
        case .fullBody: return "Full Body"
        }
    }
}

public struct Exercise: Sendable, Equatable, Identifiable {
    public let id: String
    public var name: String
    public var main: ExerciseCategoryMain

    public init(id: String, name: String, main: ExerciseCategoryMain) {
        self.id = id
        self.name = name
        self.main = main
    }
}
