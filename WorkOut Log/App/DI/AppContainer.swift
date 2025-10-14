//
//  AppContainer.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation
import SwiftData

@MainActor
final class AppContainer {
    let modelContainer: ModelContainer
    let modelContext: ModelContext

    // Data
    let sessionRepo: SessionRepository
    // Domain UseCases
    let createSession: CreateSessionUseCase
    let addSet: AddSetUseCase
    let cloneLatest: CloneLatestSessionUseCase

    init() {
        self.modelContainer = try! SwiftDataStack.container()
        self.modelContext = ModelContext(modelContainer)
        self.sessionRepo = SessionRepositoryImpl(context: modelContext)
        self.createSession = CreateSessionUseCase(repo: sessionRepo)
        self.addSet = AddSetUseCase(repo: sessionRepo)
        self.cloneLatest = CloneLatestSessionUseCase(repo: sessionRepo)
    }
}
