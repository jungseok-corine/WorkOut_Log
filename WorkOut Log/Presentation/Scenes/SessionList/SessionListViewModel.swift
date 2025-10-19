//
//  SessionListViewModel.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation
import Observation

@MainActor @Observable
final class SessionListViewModel {
    struct SessionUI: Identifiable {
        let id: String
        let date: Date
        let totalVolume: Int
        let categories: [ExerciseCategoryMain]
    }
    
    var sessions: [SessionUI] = []
    private let c: AppContainer

    var container: AppContainer { c }

    init(container: AppContainer) { self.c = container }

    func onAppear() { Task { await refresh() } }

    func refresh(range: Range<Date>? = nil) async {
        let cal = Calendar.current
        let start = range?.lowerBound ?? cal.date(byAdding: .day, value: -30, to: cal.startOfDay(for: .now))!
        let end = range?.upperBound ?? cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: .now))!

        let repo = c.sessionRepo
        let list = try? await repo.fetchRange(start: start, end: end)

        // Preserve repository sort order (date DESC, id ASC) by using indexed dictionary
        let ui = await withTaskGroup(of: (Int, SessionUI?).self) { group -> [SessionUI] in
            for (index, s) in (list ?? []).enumerated() {
                group.addTask { [c] in
                    let sets = try? await repo.fetchSets(sessionID: s.id)
                    let vol = Int((sets ?? []).map { $0.weight * Double($0.reps) }.reduce(0,+))

                    // Get unique categories from exercises in this session
                    var categories = Set<ExerciseCategoryMain>()
                    for set in sets ?? [] {
                        if let exercise = try? await c.exerciseRepo.fetch(by: set.exerciseID) {
                            categories.insert(exercise.main)
                        }
                    }

                    let sessionUI = SessionUI(
                        id: s.id,
                        date: s.date,
                        totalVolume: vol,
                        categories: Array(categories).sorted { $0.rawValue < $1.rawValue }
                    )
                    return (index, sessionUI)
                }
            }

            var resultDict: [Int: SessionUI] = [:]
            for await (index, sessionUI) in group {
                if let sessionUI = sessionUI {
                    resultDict[index] = sessionUI
                }
            }
            // Restore original order by sorting by index
            return resultDict.sorted { $0.key < $1.key }.map { $0.value }
        }
        sessions = ui
    }

    func createToday() {
        Task {
            _ = try await c.createSession(date: .now, note: nil)
            await refresh()
        }
    }

    func deleteSession(id: String) {
        Task {
            try await c.deleteSession(sessionID: id)
            await refresh()
        }
    }
}
