//
//  MainTabView.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/19/26.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    let onResetOnboarding: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDependencies) private var dependencies
    @AppStorage("didSeedRooms") private var didSeedRooms = false
    @Query private var rooms: [Room]
    @State private var seedErrorMessage: String?

    init(onResetOnboarding: @escaping () -> Void = {}) {
        self.onResetOnboarding = onResetOnboarding
    }

    private var roomRepository: any RoomRepository {
        dependencies.makeRoomRepository(modelContext)
    }
    
    var body: some View {
        TabView {
            RoomsTabView()
                .tabItem {
                    Label("Rooms", systemImage: "house")
                }

            RoomStatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }

            WeatherTabView(weatherService: dependencies.weatherService)
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun")
                }

            SettingsTabView(onResetOnboarding: onResetOnboarding)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .onAppear {
            seedRoomsIfNeeded()
        }
        .alert("Could not prepare sample rooms", isPresented: seedErrorAlertBinding) {
            Button("OK", role: .cancel) {
                seedErrorMessage = nil
            }
        } message: {
            Text(seedErrorMessage ?? "")
        }
    }

    func seedRoomsIfNeeded() {
        guard !didSeedRooms else {
            return
        }

        do {
            try roomRepository.seedSampleRoomsIfNeeded(existingRooms: rooms)
            didSeedRooms = true
        } catch {
            seedErrorMessage = error.localizedDescription
        }
    }

    private var seedErrorAlertBinding: Binding<Bool> {
        Binding {
            seedErrorMessage != nil
        } set: { isPresented in
            if !isPresented {
                seedErrorMessage = nil
            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.appDependencies, .preview)
        .environment(SubscriptionManager.preview())
        .modelContainer(for: [Room.self, RoomItem.self], inMemory: true)
}
