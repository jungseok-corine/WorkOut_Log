//
//  SessionListView.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import SwiftUI

struct SessionListView: View {
    @State var vm: SessionListViewModel
    private let container: AppContainer

    init(vm: SessionListViewModel) {
        self.vm = vm
        self.container = vm.container
    }

    var body: some View {
        NavigationStack {
            List(vm.sessions) { s in
                NavigationLink(value: s.id) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(s.date, style: .date)
                            Spacer()
                            Text("\(s.totalVolume) vol").foregroundStyle(.secondary)
                        }

                        // Category badges
                        if !s.categories.isEmpty {
                            HStack(spacing: 4) {
                                ForEach(s.categories, id: \.self) { category in
                                    Text(category.displayName)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(categoryColor(category).opacity(0.2))
                                        .foregroundStyle(categoryColor(category))
                                        .cornerRadius(4)
                                }
                            }
                            .accessibilityIdentifier("sessionRowCategories_\(s.id)")
                        }
                    }
                }
                .accessibilityIdentifier("sessionRow_\(s.id)")
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        vm.deleteSession(id: s.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .accessibilityIdentifier("deleteSession")
                }
            }
            .navigationDestination(for: String.self) { id in
                SessionDetailView(sessionID: id, container: container)
            }
            .navigationTitle("WorkoutLog")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("오늘 생성") { vm.createToday() }
                        .accessibilityIdentifier("createTodayButton")
                }
            }
            .task { vm.onAppear() }
        }
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
