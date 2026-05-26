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
    @State private var subscriptionManager = SubscriptionManager(
        purchaseService: AppDependencies.live.purchaseService
    )

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
