//
//  SettingsTabView.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/23/26.
//
import SwiftUI

struct SettingsTabView: View {
    let onResetOnboarding: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Developer") {
                    Button {
                        onResetOnboarding()
                    } label: {
                        Label("Show onboarding again", systemImage: "arrow.counterclockwise")
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
