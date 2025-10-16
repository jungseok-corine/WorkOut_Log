//
//  WorkOut_LogApp.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import SwiftUI
import SwiftData

@main
struct WorkOut_LogApp: App {
    @State private var container = AppContainer()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView(container: container)

                if showSplash {
                    SplashView(isPresented: $showSplash)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
        }
        .modelContainer(container.modelContainer)
    }
}
