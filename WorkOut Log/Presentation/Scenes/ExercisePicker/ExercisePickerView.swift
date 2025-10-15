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
                    .onChange(of: vm.searchQuery) { _, _ in
                        Task { await vm.search() }
                    }

                // Main category segmented control
                Picker("Main Category", selection: $vm.selectedMain) {
                    ForEach(ExerciseCategoryMain.allCases, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: vm.selectedMain) { _, _ in
                    vm.mainCategoryChanged()
                }

                // Upper body subcategory (only shown if upperBody selected)
                if vm.selectedMain == .upperBody {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Upper Body Part")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        ForEach(ExerciseCategoryUpper.allCases, id: \.self) { upper in
                            Button {
                                vm.selectedUpper = upper
                            } label: {
                                HStack {
                                    Image(systemName: vm.selectedUpper == upper ? "circle.fill" : "circle")
                                    Text(upper.displayName)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Recent exercises chips
                if !vm.recentExercises.isEmpty {
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

                // Search results
                List(vm.searchResults) { exercise in
                    Button {
                        onSelect(exercise)
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                Text(exercise.main.displayName + (exercise.upper.map { " - \($0.displayName)" } ?? ""))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
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
                        Task {
                            if let exercise = await vm.createExercise(name: vm.searchQuery) {
                                onSelect(exercise)
                                dismiss()
                            }
                        }
                    }
                    .accessibilityIdentifier("saveExerciseSelection")
                    .disabled(!vm.isValid || vm.searchQuery.isEmpty)
                }
            }
            .task {
                vm.onAppear()
            }
        }
    }
}
