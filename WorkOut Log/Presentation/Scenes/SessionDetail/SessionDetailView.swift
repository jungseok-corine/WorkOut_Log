//
//  SessionDetailView.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import SwiftUI

struct SessionDetailView: View {
    let sessionID: String
    @State private var exerciseID: String = "lat-pulldown" // 임시
    @State private var weight: String = ""
    @State private var reps: String = ""
    @State private var sets: [SetRecord] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let container: AppContainer

    init(sessionID: String, container: AppContainer) {
        self.sessionID = sessionID
        self.container = container
    }

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    if sets.isEmpty {
                        Text("No sets yet. Add your first set below!")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(sets, id: \.id) { set in
                            HStack {
                                Text("#\(set.order + 1)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(Int(set.weight))kg × \(set.reps) reps")
                                    .font(.body.monospacedDigit())
                                Spacer()
                                Text("\(Int(set.volume))kg total")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }

                // Add Set Section
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        TextField("Weight (kg)", text: $weight)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)

                        TextField("Reps", text: $reps)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)

                        Button("Add Set") {
                            Task { await addSetTapped() }
                        }
                        .accessibilityIdentifier("addSetButton")
                        .buttonStyle(.borderedProminent)
                        .disabled(weight.isEmpty || reps.isEmpty || isLoading)
                    }

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
        }
        .navigationTitle("Session Detail")
        .navigationBarTitleDisplayMode(.inline)
        .task { await reload() }
    }

    private func addSetTapped() async {
        guard let w = Double(weight), let r = Int(reps) else {
            errorMessage = "Please enter valid weight and reps"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let order = sets.count
            _ = try await container.addSet(sessionID: sessionID, exerciseID: exerciseID, weight: w, reps: r, order: order)
            await reload()

            // Clear inputs on success
            weight = ""
            reps = ""
        } catch {
            errorMessage = "Failed to add set: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func reload() async {
        isLoading = true

        do {
            let fetchedSets = try await container.sessionRepo.fetchSets(sessionID: sessionID)
            sets = fetchedSets
        } catch {
            errorMessage = "Failed to load sets: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
