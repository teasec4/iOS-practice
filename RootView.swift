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
    @State private var rootState: RootState = .splash

    var body: some View {
        Group {
            switch rootState {
            case .splash:
                SplashView()
            case .main:
                ContentView {
                    userProfileData = ""
                    hasCompletedOnboarding = false
                    rootState = .onboarding
                }
                .transition(.opacity)
            case .onboarding:
                OnboardingFlowView { userProfile in
                    userProfileData = userProfile.encoded()
                    hasCompletedOnboarding = true
                    rootState = .main
                }
                .transition(.opacity)
            }
        }
        .animation(.smooth, value: rootState)
        .task {
            await finishSplash()
        }
        .onChange(of: hasCompletedOnboarding) {
            guard rootState != .splash else {
                return
            }

            rootState = currentDestination
        }
    }

    private var currentDestination: RootState {
        hasCompletedOnboarding ? .main : .onboarding
    }

    private func finishSplash() async {
        guard rootState == .splash else {
            return
        }

        try? await Task.sleep(nanoseconds: 1_700_000_000)

        guard !Task.isCancelled else {
            return
        }

        rootState = currentDestination
    }
}

private enum RootState {
    case splash
    case onboarding
    case main
}

#Preview {
    RootView()
        .environment(\.appDependencies, .preview)
        .environment(SubscriptionManager.preview())
        .modelContainer(for: [Room.self, RoomItem.self], inMemory: true)
}
