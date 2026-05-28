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
    private let dependencies: AppDependencies
    @State private var subscriptionManager: SubscriptionManager

    init() {
        let dependencies = AppDependencies.live
        self.dependencies = dependencies
        self._subscriptionManager = State(
            initialValue: SubscriptionManager(purchaseService: dependencies.purchaseService)
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appDependencies, dependencies)
                .environment(subscriptionManager)
                .task {
                    await subscriptionManager.start()
                }
        }
        .modelContainer(for: [Room.self, RoomItem.self])
    }
}
