//
//  SessionListView.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import SwiftUI

struct SessionListView: View {
    @State var vm: SessionListViewModel
    init(vm: SessionListViewModel) { self.vm = vm }

    var body: some View {
        NavigationStack {
            List(vm.sessions) { s in
                NavigationLink(value: s.id) {
                    HStack {
                        Text(s.date, style: .date)
                        Spacer()
                        Text("\(s.totalVolume) vol").foregroundStyle(.secondary)
                    }
                }
            }
            .navigationDestination(for: String.self) { id in
                SessionDetailView(sessionID: id, container: nil) // 컨테이너 주입 방식 자유
            }
            .navigationTitle("WorkoutLog")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("오늘 생성") { vm.createToday() }
                        .accessibilityIdentifier("createTodayButton")
                    Button("최근 복제") { vm.cloneLatestToToday() }
                        .accessibilityIdentifier("cloneLatestButton")
                }
            }
            .task { vm.onAppear() }
        }
    }
}
