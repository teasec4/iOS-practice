//
//  AppDependencies.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/22/26.
//
import SwiftData
import SwiftUI

struct AppDependencies: Sendable {
    let weatherService: any WeatherService
    let makeRoomRepository: @MainActor @Sendable (ModelContext) -> any RoomRepository
}

extension AppDependencies {
    static let live = AppDependencies(
        weatherService: OpenMeteoWeatherService(),
        makeRoomRepository: { modelContext in
            SwiftDataRoomRepository(modelContext: modelContext)
        }
    )

    static let preview = AppDependencies(
        weatherService: MockWeatherService(),
        makeRoomRepository: { modelContext in
            SwiftDataRoomRepository(modelContext: modelContext)
        }
    )
}

private struct AppDependenciesKey: EnvironmentKey {
    static let defaultValue = AppDependencies.live
}

extension EnvironmentValues {
    var appDependencies: AppDependencies {
        get { self[AppDependenciesKey.self] }
        set { self[AppDependenciesKey.self] = newValue }
    }
}
