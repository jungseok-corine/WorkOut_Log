//
//  MainTabView.swift
//  WorkOut Log
//
//  Created by Claude on 15/10/2025.
//

import SwiftUI

struct MainTabView: View {
    let container: AppContainer

    var body: some View {
        TabView {
            SessionListView(vm: SessionListViewModel(container: container))
                .tabItem {
                    Label("Log", systemImage: "list.bullet.clipboard")
                }

            TrendsView(vm: TrendsViewModel(container: container))
                .tabItem {
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
    }
}
