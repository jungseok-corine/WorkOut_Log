//
//  ExercisePickerView.swift
//  WorkOut Log
//
//  Created by Claude on 15/10/2025.
//

import SwiftUI

struct ExercisePickerView: View {
    @State var vm: ExercisePickerViewModel
    @Environment(\.dismiss) var dismiss
    let onSelect: (Exercise) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Search bar
                TextField("Search exercises...", text: $vm.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .onChange(of: vm.searchQuery) { _, newValue in
                        vm.debouncedSearch(newValue)
                    }

                // Recent exercises chips
                if !vm.recentExercises.isEmpty && vm.searchQuery.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(vm.recentExercises) { exercise in
                                    Button {
                                        onSelect(exercise)
                                        dismiss()
                                    } label: {
                                        Text(exercise.name)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(16)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // Error message
                if let errorMessage = vm.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                // Search results grouped by main category
                List {
                    ForEach(ExerciseCategoryMain.allCases, id: \.self) { category in
                        let exercises = vm.searchResults.filter { $0.main == category }
                        if !exercises.isEmpty {
                            Section(header: Text(category.displayName)) {
                                ForEach(exercises) { exercise in
                                    Button {
                                        onSelect(exercise)
                                        dismiss()
                                    } label: {
                                        HStack {
                                            Text(exercise.name)
                                            Spacer()
                                        }
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            Task {
                                                await vm.deleteExercise(id: exercise.id)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        .accessibilityIdentifier("deleteExercise")
                                    }
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create New") {
                        vm.showCreateSheet = true
                    }
                    .accessibilityIdentifier("createExerciseButton")
                }
            }
            .sheet(isPresented: $vm.showCreateSheet) {
                CreateExerciseSheet(
                    vm: vm,
                    onSave: { exercise in
                        onSelect(exercise)
                        dismiss()
                    }
                )
            }
            .task {
                vm.onAppear()
            }
        }
    }
}

struct CreateExerciseSheet: View {
    @State var vm: ExercisePickerViewModel
    @Environment(\.dismiss) var dismiss
    let onSave: (Exercise) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Details") {
                    TextField("Name (e.g., bench press, squat)", text: $vm.newExerciseName)
                        .accessibilityIdentifier("exerciseNameField")

                    Picker("Main Category", selection: $vm.newExerciseMain) {
                        ForEach(ExerciseCategoryMain.allCases, id: \.self) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                    .accessibilityIdentifier("mainCategoryPicker")
                }

                if let errorMessage = vm.errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Create Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if let exercise = await vm.createExercise() {
                                onSave(exercise)
                            } else {
                                // Error is already set in errorMessage
                            }
                        }
                    }
                    .accessibilityIdentifier("saveExerciseButton")
                    .disabled(vm.newExerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
