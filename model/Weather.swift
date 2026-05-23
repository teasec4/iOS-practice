//
//  Weather.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/22/26.
//
import Foundation

struct WeatherCity: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double

    init(name: String, latitude: Double, longitude: Double) {
        self.id = name
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension WeatherCity {
    static let shanghai = WeatherCity(name: "Shanghai", latitude: 31.2304, longitude: 121.4737)

    static let availableCities: [WeatherCity] = [
        .shanghai,
        WeatherCity(name: "San Francisco", latitude: 37.7749, longitude: -122.4194),
        WeatherCity(name: "London", latitude: 51.5072, longitude: -0.1276),
        WeatherCity(name: "Moscow", latitude: 55.7558, longitude: 37.6173)
    ]
}

struct CurrentWeather: Sendable {
    let city: WeatherCity
    let temperature: Double
    let apparentTemperature: Double
    let humidity: Double
    let windSpeed: Double
    let weatherCode: Int
    let updatedAt: String
    let temperatureUnit: String
    let windSpeedUnit: String

    var conditionTitle: String {
        switch weatherCode {
        case 0:
            "Clear sky"
        case 1, 2, 3:
            "Partly cloudy"
        case 45, 48:
            "Fog"
        case 51, 53, 55, 56, 57:
            "Drizzle"
        case 61, 63, 65, 66, 67:
            "Rain"
        case 71, 73, 75, 77:
            "Snow"
        case 80, 81, 82:
            "Rain showers"
        case 85, 86:
            "Snow showers"
        case 95, 96, 99:
            "Thunderstorm"
        default:
            "Unknown"
        }
    }

    var symbolName: String {
        switch weatherCode {
        case 0:
            "sun.max"
        case 1, 2, 3:
            "cloud.sun"
        case 45, 48:
            "cloud.fog"
        case 51, 53, 55, 56, 57:
            "cloud.drizzle"
        case 61, 63, 65, 66, 67, 80, 81, 82:
            "cloud.rain"
        case 71, 73, 75, 77, 85, 86:
            "cloud.snow"
        case 95, 96, 99:
            "cloud.bolt.rain"
        default:
            "cloud"
        }
    }
}
