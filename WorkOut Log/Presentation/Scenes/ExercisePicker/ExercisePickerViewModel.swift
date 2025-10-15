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
    var selectedMain: ExerciseCategoryMain = .upperBody
    var selectedUpper: ExerciseCategoryUpper?
    var searchResults: [Exercise] = []
    var recentExercises: [Exercise] = []

    private let container: AppContainer

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
        do {
            let results = try await container.searchExercises(query: searchQuery.isEmpty ? "" : searchQuery, main: nil)
            searchResults = results
        } catch {
            print("Search failed: \(error)")
        }
    }

    func loadRecent() async {
        do {
            recentExercises = try await container.recentExercises(limit: 5)
        } catch {
            print("Load recent failed: \(error)")
        }
    }

    func mainCategoryChanged() {
        // Reset upper selection when main changes
        if selectedMain != .upperBody {
            selectedUpper = nil
        }
    }

    func createExercise(name: String) async -> Exercise? {
        guard !name.isEmpty else { return nil }

        // Validate: upperBody requires upper subcategory
        if selectedMain == .upperBody && selectedUpper == nil {
            return nil
        }

        do {
            let exercise = try await container.upsertExercise(
                name: name,
                main: selectedMain,
                upper: selectedUpper
            )
            return exercise
        } catch {
            print("Create exercise failed: \(error)")
            return nil
        }
    }

    var isValid: Bool {
        if selectedMain == .upperBody {
            return selectedUpper != nil
        }
        return true
    }
}
