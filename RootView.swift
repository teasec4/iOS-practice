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
    @AppStorage("userProfileData") private var userProfileData = ""

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                ContentView {
                    userProfileData = ""
                    hasCompletedOnboarding = false
                }
            } else {
                OnboardingFlowView { userProfile in
                    userProfileData = userProfile.encoded()
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
        .environment(SubscriptionManager.preview())
        .modelContainer(for: [Room.self, RoomItem.self], inMemory: true)
}
