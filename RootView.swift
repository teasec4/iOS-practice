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
    @AppStorage("isProUser") private var isProUser = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                ContentView {
                    isProUser = false
                    hasCompletedOnboarding = false
                }
            } else {
                OnboardingFlowView { didStartTrial in
                    isProUser = didStartTrial
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
