//
//  TrendsViewModel.swift
//  WorkOut Log
//
//  Created by Claude on 15/10/2025.
//

import Foundation
import Observation

@MainActor @Observable
final class TrendsViewModel {
    var scope: TrendScope = .weekly
    var selectedCategory: ExerciseCategoryMain?
    var showAllDays: Bool = false // Only relevant for daily scope
    var trendData: [VolumeTrendPoint] = []
    var isLoading = false

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    func onAppear() {
        Task {
            await refresh()
        }
    }

    func refresh() async {
        isLoading = true
        do {
            let includeZeroDays = scope == .daily ? showAllDays : false
            trendData = try await container.computeVolumeTrend(
                scope: scope,
                categoryFilter: selectedCategory,
                includeZeroDays: includeZeroDays
            )
        } catch {
            print("Failed to load trend: \(error)")
            trendData = []
        }
        isLoading = false
    }

    func scopeChanged() {
        Task {
            await refresh()
        }
    }

    func categoryFilterChanged() {
        Task {
            await refresh()
        }
    }

    func showAllDaysToggled() {
        Task {
            await refresh()
        }
    }
}
