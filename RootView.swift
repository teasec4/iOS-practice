//
//  RootView.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/23/26.
//
import SwiftUI
import SwiftData

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                ContentView {
                    hasCompletedOnboarding = false
                }
            } else {
                OnboardingFlowView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .animation(.smooth, value: hasCompletedOnboarding)
    }
}

#Preview {
    RootView()
        .environment(\.appDependencies, .preview)
        .modelContainer(for: [Room.self, RoomItem.self], inMemory: true)
}
