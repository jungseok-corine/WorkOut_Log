//
//  Exercise.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

public struct Exercise: Sendable, Equatable, Identifiable {
    public let id: String
    public var name: String
    public var bodyPart: String?
    public init(id: String, name: String, bodyPart: String? = nil) {
        self.id = id; self.name = name; self.bodyPart = bodyPart
    }
}
