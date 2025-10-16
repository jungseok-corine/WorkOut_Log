//
//  ExercisePickerViewModel.swift
//  WorkOut Log
//
//  Created by Claude on 15/10/2025.
//

import Foundation
import Observation

@MainActor @Observable
final class ExercisePickerViewModel {
    var searchQuery: String = ""
    var searchResults: [Exercise] = []
    var recentExercises: [Exercise] = []
    var errorMessage: String?

    // For create sheet
    var showCreateSheet = false
    var newExerciseName = ""
    var newExerciseMain: ExerciseCategoryMain = .upperBody

    private let container: AppContainer
    private var searchTask: Task<Void, Never>?

    init(container: AppContainer) {
        self.container = container
    }

    func onAppear() {
        Task {
            await loadRecent()
            await search()
        }
    }

    func search() async {
        searchTask?.cancel()

        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            // Show recent exercises when search is empty
            do {
                searchResults = try await container.recentExercises(limit: 20)
            } catch {
                print("Load recent failed: \(error)")
            }
            return
        }

        // Use localizedStandardContains for better search
        do {
            let results = try await container.searchExercises(query: query, main: nil)
            searchResults = results
        } catch {
            print("Search failed: \(error)")
            errorMessage = "Search failed: \(error.localizedDescription)"
        }
    }

    func debouncedSearch(_ newValue: String) {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
            if !Task.isCancelled {
                await search()
            }
        }
    }

    func loadRecent() async {
        do {
            recentExercises = try await container.recentExercises(limit: 5)
        } catch {
            print("Load recent failed: \(error)")
        }
    }

    func createExercise() async -> Exercise? {
        let name = newExerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            errorMessage = "Exercise name cannot be empty"
            return nil
        }

        do {
            let exercise = try await container.upsertExercise(
                name: name,
                main: newExerciseMain
            )
            // Refresh lists
            await loadRecent()
            await search()
            // Reset form
            newExerciseName = ""
            newExerciseMain = .upperBody
            return exercise
        } catch {
            print("Create exercise failed: \(error)")
            errorMessage = "Failed to create exercise: \(error.localizedDescription)"
            return nil
        }
    }

    func deleteExercise(id: String) async {
        do {
            try await container.deleteExercise(id: id)
            await loadRecent()
            await search()
            errorMessage = nil
        } catch {
            print("Delete exercise failed: \(error)")
            let nsError = error as NSError
            if nsError.code == 2 {
                errorMessage = "Cannot delete: exercise has existing sets"
            } else {
                errorMessage = "Failed to delete exercise: \(error.localizedDescription)"
            }
        }
    }
}
