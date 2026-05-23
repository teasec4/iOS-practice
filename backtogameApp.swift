//
//  backtogameApp.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/19/26.
//

import SwiftUI
import SwiftData

@main
struct backtogameApp: App {
    private let dependencies = AppDependencies.live

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appDependencies, dependencies)
        }
        .modelContainer(for: [Room.self, RoomItem.self])
    }
}
