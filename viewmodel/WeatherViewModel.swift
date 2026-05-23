//
//  WeatherViewModel.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/22/26.
//
import Foundation
import Observation

enum WeatherViewState {
    case idle
    case loading
    case loaded(CurrentWeather)
    case failed(String)
}

@MainActor
@Observable
final class WeatherViewModel {
    var selectedCity: WeatherCity = .shanghai
    var state: WeatherViewState = .idle

    var isLoading: Bool {
        if case .loading = state {
            return true
        }

        return false
    }

    private var didLoad = false
    private let weatherService: any WeatherService

    init(weatherService: any WeatherService) {
        self.weatherService = weatherService
    }

    func loadWeatherIfNeeded() async {
        guard !didLoad else {
            return
        }

        await loadWeather()
    }

    func loadWeather() async {
        let city = selectedCity
        state = .loading

        do {
            let weather = try await weatherService.fetchCurrentWeather(for: city)

            guard city == selectedCity else {
                return
            }

            state = .loaded(weather)
            didLoad = true
        } catch {
            guard city == selectedCity else {
                return
            }

            state = .failed(error.localizedDescription)
        }
    }
}
