//
//  AppDependencies.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/22/26.
//
import SwiftData
import SwiftUI

struct AppDependencies: Sendable {
    // апи для теста
    let weatherService: any WeatherService

    // реализация через сторкит
    let purchaseService: any PurchaseService

    // БД иницаилаизируется немного позже поэтому получаем контекст
    // репозитоии для работы с данными
    let makeRoomRepository: @MainActor @Sendable (ModelContext) -> any RoomRepository
    let makeRoomItemRepository: @MainActor @Sendable (ModelContext) -> any RoomItemRepository
}

extension AppDependencies {
    static let live = AppDependencies(
        weatherService: OpenMeteoWeatherService(),
        purchaseService: StoreKitPurchaseService(),
        makeRoomRepository: { modelContext in
            SwiftDataRoomRepository(modelContext: modelContext)
        },
        makeRoomItemRepository: { modelContext in
            SwiftDataRoomItemRepository(modelContext: modelContext)
        }
    )

    static let preview = AppDependencies(
        weatherService: MockWeatherService(),
        purchaseService: PreviewPurchaseService(),
        makeRoomRepository: { modelContext in
            SwiftDataRoomRepository(modelContext: modelContext)
        },
        makeRoomItemRepository: { modelContext in
            SwiftDataRoomItemRepository(modelContext: modelContext)
        }
    )
}

// regestration env key for dependensies
private struct AppDependenciesKey: EnvironmentKey {
    static let defaultValue = AppDependencies.live
}

// easy way to get a value .environment(\.appDependencies, .live)
extension EnvironmentValues {
    var appDependencies: AppDependencies {
        get { self[AppDependenciesKey.self] }
        set { self[AppDependenciesKey.self] = newValue }
    }
}
