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

    // Data Repositories
    let sessionRepo: SessionRepository
    let exerciseRepo: ExerciseRepository
    let bodyMetricRepo: BodyMetricRepository

    // Session UseCases
    let createSession: CreateSessionUseCase
    let deleteSession: DeleteSessionUseCase
    let addSet: AddSetUseCase
    let updateSet: UpdateSetUseCase
    let deleteSet: DeleteSetUseCase
    let cloneLatest: CloneLatestSessionUseCase

    // Exercise UseCases
    let upsertExercise: UpsertExerciseUseCase
    let searchExercises: SearchExercisesUseCase
    let recentExercises: RecentExercisesUseCase

    // Analytics UseCases
    let computeVolumesByCategory: ComputeVolumesByCategoryUseCase
    let computePR: ComputePRUseCase

    // Body Metrics UseCases
    let createBodyMetric: CreateBodyMetricUseCase
    let fetchBodyMetricsRange: FetchBodyMetricsRangeUseCase

    init() {
        self.modelContainer = try! SwiftDataStack.container()
        self.modelContext = ModelContext(modelContainer)

        // Initialize repositories
        self.sessionRepo = SessionRepositoryImpl(context: modelContext)
        self.exerciseRepo = ExerciseRepositoryImpl(context: modelContext)
        self.bodyMetricRepo = BodyMetricRepositoryImpl(context: modelContext)

        // Initialize session use cases
        self.createSession = CreateSessionUseCase(repo: sessionRepo)
        self.deleteSession = DeleteSessionUseCase(repo: sessionRepo)
        self.addSet = AddSetUseCase(repo: sessionRepo)
        self.updateSet = UpdateSetUseCase(repo: sessionRepo)
        self.deleteSet = DeleteSetUseCase(repo: sessionRepo)
        self.cloneLatest = CloneLatestSessionUseCase(repo: sessionRepo)

        // Initialize exercise use cases
        self.upsertExercise = UpsertExerciseUseCase(repo: exerciseRepo)
        self.searchExercises = SearchExercisesUseCase(repo: exerciseRepo)
        self.recentExercises = RecentExercisesUseCase(repo: exerciseRepo)

        // Initialize analytics use cases
        self.computeVolumesByCategory = ComputeVolumesByCategoryUseCase(
            sessionRepo: sessionRepo,
            exerciseRepo: exerciseRepo
        )
        self.computePR = ComputePRUseCase(sessionRepo: sessionRepo)

        // Initialize body metrics use cases
        self.createBodyMetric = CreateBodyMetricUseCase(repo: bodyMetricRepo)
        self.fetchBodyMetricsRange = FetchBodyMetricsRangeUseCase(repo: bodyMetricRepo)
    }
}
