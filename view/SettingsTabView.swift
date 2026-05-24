//
//  SettingsTabView.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/23/26.
//
import SwiftUI

struct SettingsTabView: View {
    let onResetOnboarding: () -> Void
    @AppStorage("isProUser") private var isProUser = false

    var body: some View {
        NavigationStack {
            List {
                Section("Plan") {
                    HStack {
                        Label(isProUser ? "Pro" : "Free", systemImage: isProUser ? "crown" : "person")
                        Spacer()
                        Text(isProUser ? "Trial active" : "Free version")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Developer") {
                    Button {
                        onResetOnboarding()
                    } label: {
                        Label("Reset onboarding and subscription", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsTabView {}
}
