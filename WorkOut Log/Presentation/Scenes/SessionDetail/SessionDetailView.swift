//
//  SessionDetailView.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import SwiftUI

struct SessionDetailView: View {
    let sessionID: String
    @Environment(\.modelContext) private var ctx
    @State private var exerciseID: String = "lat-pulldown" // 임시
    @State private var weight: String = ""
    @State private var reps: String = ""
    @State private var sets: [SetRecord] = []
    private let container: AppContainer?

    init(sessionID: String, container: AppContainer?) {
        self.sessionID = sessionID; self.container = container
    }

    var body: some View {
        VStack {
            List {
                ForEach(sets, id: \.id) { s in
                    HStack {
                        Text("#\(s.order+1)")
                        Spacer()
                        Text("\(Int(s.weight))kg × \(s.reps)")
                    }
                }
            }
            HStack {
                TextField("무게", text: $weight).keyboardType(.decimalPad)
                TextField("횟수", text: $reps).keyboardType(.numberPad)
                Button("추가") { addSetTapped() }
            }
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
        }
        .navigationTitle("세션 상세")
        .task { await reload() }
    }

    private func addSetTapped() {
        guard let w = Double(weight), let r = Int(reps),
              let c = container else { return }
        Task {
            let order = sets.count
            _ = try await c.addSet(sessionID: sessionID, exerciseID: exerciseID, weight: w, reps: r, order: order)
            await reload()
            weight = ""; reps = ""
        }
    }

    private func reload() async {
        guard let repo = container?.sessionRepo else { return }
        if let list = try? await repo.fetchSets(sessionID: sessionID) {
            await MainActor.run { self.sets = list }
        }
    }
}
