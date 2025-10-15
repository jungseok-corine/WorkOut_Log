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
    
    var body: some Scene {
        WindowGroup {
            MainTabView(container: container)
        }
        .modelContainer(container.modelContainer)
    }
}
