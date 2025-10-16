//
//  SessionDetailView.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import SwiftUI

struct SessionDetailView: View {
    @State var vm: SessionDetailViewModel
    @State private var showExercisePicker = false
    private let container: AppContainer

    init(sessionID: String, container: AppContainer) {
        self.container = container
        self._vm = State(initialValue: SessionDetailViewModel(sessionID: sessionID, container: container))
    }

    var body: some View {
        VStack(spacing: 0) {
            if vm.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    if vm.exerciseGroups.isEmpty {
                        Text("No sets yet. Add your first set below!")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(vm.exerciseGroups) { group in
                            Section {
                                ForEach(Array(group.sets.enumerated()), id: \.element.id) { index, set in
                                    HStack {
                                        Text("#\(index + 1)")
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
                                    .accessibilityIdentifier("setRow_\(set.id)")
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            Task { await vm.deleteSet(setID: set.id) }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        .accessibilityIdentifier("deleteSet")
                                    }
                                }
                            } header: {
                                HStack(spacing: 8) {
                                    Text(group.name)
                                        .font(.headline)
                                    Text(group.main.displayName)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(categoryColor(group.main).opacity(0.2))
                                        .foregroundStyle(categoryColor(group.main))
                                        .cornerRadius(4)
                                }
                                .accessibilityIdentifier("exerciseSection_\(group.id)")
                            } footer: {
                                Text("Total: \(group.totalVolume)kg")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .accessibilityIdentifier("exerciseSubtotal_\(group.id)")
                            }
                        }
                    }
                }

                // Add Set Section
                VStack(spacing: 12) {
                    // Selected exercise display
                    if let exercise = vm.currentExercise {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Current: \(exercise.name)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text(exercise.main.displayName)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .cornerRadius(8)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        .accessibilityIdentifier("selectedExerciseLabel")
                    }

                    // Exercise selection button
                    Button {
                        showExercisePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "dumbbell.fill")
                            if vm.currentExercise == nil {
                                Text("Select Exercise")
                            } else {
                                Text("Change Exercise")
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    }
                    .accessibilityIdentifier("openExercisePicker")

                    HStack(spacing: 12) {
                        TextField("Weight (kg)", text: $vm.weight)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)

                        TextField("Reps", text: $vm.reps)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)

                        Button("Add Set") {
                            Task { await vm.addSet() }
                        }
                        .accessibilityIdentifier("addSetButton")
                        .buttonStyle(.borderedProminent)
                        .disabled(vm.currentExercise == nil || vm.weight.isEmpty || vm.reps.isEmpty || vm.isLoading)
                    }

                    if let errorMessage = vm.errorMessage {
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
        .sheet(isPresented: $showExercisePicker) {
            ExercisePickerView(
                vm: ExercisePickerViewModel(container: container),
                onSelect: { exercise in
                    vm.currentExercise = exercise
                }
            )
        }
        .task { vm.onAppear() }
    }

    private func categoryColor(_ category: ExerciseCategoryMain) -> Color {
        switch category {
        case .lowerBody: return .blue
        case .upperBody: return .orange
        case .cardio: return .red
        case .fullBody: return .purple
        }
    }
}
