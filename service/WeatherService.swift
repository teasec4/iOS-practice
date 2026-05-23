//
//  WeatherService.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/22/26.
//
import Foundation

protocol WeatherService: Sendable {
    func fetchCurrentWeather(for city: WeatherCity) async throws -> CurrentWeather
}

enum WeatherServiceError: LocalizedError {
    case invalidURL
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Could not build weather request."
        case .invalidResponse:
            "Weather service returned an invalid response."
        }
    }
}
