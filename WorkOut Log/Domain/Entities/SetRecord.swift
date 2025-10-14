//
//  SetRecord.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

public struct SetRecord: Sendable, Equatable, Identifiable {
    public let id: String
    public var sessionID: String
    public var exerciseID: String
    public var weight: Double
    public var reps: Int
    public var order: Int
    public var volume: Double { weight * Double(reps) }
    public init(id: String, sessionID: String, exerciseID: String,
                weight: Double, reps: Int, order: Int) {
        self.id = id; self.sessionID = sessionID; self.exerciseID = exerciseID
        self.weight = weight; self.reps = reps; self.order = order
    }
}
