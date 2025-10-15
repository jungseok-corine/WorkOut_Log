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

// Upper body subcategory (소분류 - only for upperBody)
public enum ExerciseCategoryUpper: String, Sendable, CaseIterable, Codable {
    case chest
    case back
    case biceps
    case triceps
    case trapezius

    public var displayName: String {
        switch self {
        case .chest: return "Chest"
        case .back: return "Back"
        case .biceps: return "Biceps"
        case .triceps: return "Triceps"
        case .trapezius: return "Trapezius"
        }
    }
}

public struct Exercise: Sendable, Equatable, Identifiable {
    public let id: String
    public var name: String
    public var main: ExerciseCategoryMain
    public var upper: ExerciseCategoryUpper?

    public init(id: String, name: String, main: ExerciseCategoryMain, upper: ExerciseCategoryUpper? = nil) {
        self.id = id
        self.name = name
        self.main = main
        self.upper = upper
    }

    // Validation: upperBody must have upper subcategory
    public var isValid: Bool {
        if main == .upperBody {
            return upper != nil
        }
        return upper == nil
    }
}
