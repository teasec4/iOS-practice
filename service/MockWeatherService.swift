//
//  MockWeatherService.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/22/26.
//
import Foundation

struct MockWeatherService: WeatherService {
    let shouldFail: Bool

    init(shouldFail: Bool = false) {
        self.shouldFail = shouldFail
    }

    func fetchCurrentWeather(for city: WeatherCity) async throws -> CurrentWeather {
        if shouldFail {
            throw WeatherServiceError.invalidResponse
        }

        return CurrentWeather(
            city: city,
            temperature: 21,
            apparentTemperature: 22,
            humidity: 55,
            windSpeed: 8,
            weatherCode: 2,
            updatedAt: "Preview",
            temperatureUnit: "\u{00B0}C",
            windSpeedUnit: "km/h"
        )
    }
}
