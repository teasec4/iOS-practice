//
//  ContentView.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/19/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    let onResetOnboarding: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDependencies) private var dependencies
    @AppStorage("didSeedRooms") private var didSeedRooms = false
    @Query private var rooms: [Room]

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
    }

    func seedRoomsIfNeeded() {
        guard !didSeedRooms else {
            return
        }

        roomRepository.seedSampleRoomsIfNeeded(existingRooms: rooms)
        didSeedRooms = true
    }
}

#Preview {
    ContentView()
        .environment(\.appDependencies, .preview)
        .modelContainer(for: Room.self, inMemory: true)
}
