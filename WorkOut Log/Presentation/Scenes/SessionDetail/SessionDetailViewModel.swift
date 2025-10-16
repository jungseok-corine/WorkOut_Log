//
//  SessionDetailViewModel.swift
//  WorkOut Log
//
//  Created by Claude on 16/10/2025.
//

import Foundation
import Observation

@MainActor @Observable
final class SessionDetailViewModel {
    // MARK: - UI Models

    struct SetUI: Identifiable {
        let id: String
        let weight: Double
        let reps: Int
        let volume: Double
        let order: Int // original global order
    }

    struct ExerciseGroupUI: Identifiable {
        let id: String // exerciseID
        let name: String
        let main: ExerciseCategoryMain
        let totalVolume: Int
        let sets: [SetUI]
        let firstSetOrder: Int // for stable sorting
    }

    // MARK: - Published State

    var exerciseGroups: [ExerciseGroupUI] = []
    var currentExercise: Exercise?
    var isLoading = false
    var errorMessage: String?

    // MARK: - Input State

    var weight: String = ""
    var reps: String = ""

    // MARK: - Dependencies

    private let sessionID: String
    private let container: AppContainer

    init(sessionID: String, container: AppContainer) {
        self.sessionID = sessionID
        self.container = container
    }

    // MARK: - Actions

    func onAppear() {
        Task {
            await reload()
        }
    }

    func addSet() async {
        guard let exercise = currentExercise else {
            errorMessage = "Please select an exercise first"
            return
        }

        guard let w = Double(weight), let r = Int(reps), w > 0, r > 0 else {
            errorMessage = "Please enter valid weight and reps"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Fetch current sets to compute next order
            let currentSets = try await container.sessionRepo.fetchSets(sessionID: sessionID)
            let order = currentSets.count

            _ = try await container.addSet(
                sessionID: sessionID,
                exerciseID: exercise.id,
                weight: w,
                reps: r,
                order: order
            )

            await reload()

            // Clear inputs on success
            weight = ""
            reps = ""
        } catch {
            errorMessage = "Failed to add set: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func deleteSet(setID: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await container.deleteSet(setID: setID)
            await reload()
        } catch {
            errorMessage = "Failed to delete set: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func reload() async {
        isLoading = true

        do {
            let sets = try await container.sessionRepo.fetchSets(sessionID: sessionID)

            // Get unique exercise IDs
            let exerciseIDs = Set(sets.map { $0.exerciseID })

            // Fetch all exercises in one go
            var exercisesDict: [String: Exercise] = [:]
            for id in exerciseIDs {
                if let exercise = try await container.exerciseRepo.fetch(by: id) {
                    exercisesDict[id] = exercise
                }
            }

            // Group sets by exercise
            let grouped = Dictionary(grouping: sets) { $0.exerciseID }

            // Map to UI models
            let groups = grouped.compactMap { (exerciseID, sets) -> ExerciseGroupUI? in
                guard let exercise = exercisesDict[exerciseID] else { return nil }

                let sortedSets = sets.sorted { $0.order < $1.order }
                let setUIs = sortedSets.map { set in
                    SetUI(
                        id: set.id,
                        weight: set.weight,
                        reps: set.reps,
                        volume: set.volume,
                        order: set.order
                    )
                }

                let totalVol = Int(setUIs.reduce(0) { $0 + $1.volume })
                let firstOrder = sortedSets.first?.order ?? 0

                return ExerciseGroupUI(
                    id: exerciseID,
                    name: exercise.name,
                    main: exercise.main,
                    totalVolume: totalVol,
                    sets: setUIs,
                    firstSetOrder: firstOrder
                )
            }

            // Sort groups by first set appearance (stable order)
            exerciseGroups = groups.sorted { $0.firstSetOrder < $1.firstSetOrder }

        } catch {
            errorMessage = "Failed to load sets: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
