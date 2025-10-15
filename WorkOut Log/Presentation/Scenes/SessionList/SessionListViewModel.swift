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

        let ui = await withTaskGroup(of: SessionUI?.self) { group -> [SessionUI] in
            for s in list ?? [] {
                group.addTask {
                    let sets = try? await repo.fetchSets(sessionID: s.id)
                    let vol = Int((sets ?? []).map { $0.weight * Double($0.reps) }.reduce(0,+))
                    return SessionUI(id: s.id, date: s.date, totalVolume: vol)
                }
            }

            var result: [SessionUI] = []
            for await sessionUI in group {
                if let sessionUI = sessionUI {
                    result.append(sessionUI)
                }
            }
            return result
        }
        sessions = ui
    }

    func createToday() {
        Task {
            _ = try await c.createSession(date: .now, note: nil)
            await refresh()
        }
    }

    func cloneLatestToToday() {
        Task {
            _ = try await c.cloneLatest(newDate: .now)
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
