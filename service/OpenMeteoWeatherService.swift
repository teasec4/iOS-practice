//
//  OpenMeteoWeatherService.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/22/26.
//
import Foundation

struct OpenMeteoWeatherService: WeatherService {
    func fetchCurrentWeather(for city: WeatherCity) async throws -> CurrentWeather {
        let url = try makeURL(for: city)
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw WeatherServiceError.invalidResponse
        }

        let dto = try JSONDecoder().decode(OpenMeteoWeatherResponse.self, from: data)

        return CurrentWeather(
            city: city,
            temperature: dto.current.temperature2m,
            apparentTemperature: dto.current.apparentTemperature,
            humidity: dto.current.relativeHumidity2m,
            windSpeed: dto.current.windSpeed10m,
            weatherCode: dto.current.weatherCode,
            updatedAt: dto.current.time,
            temperatureUnit: dto.currentUnits.temperature2m,
            windSpeedUnit: dto.currentUnits.windSpeed10m
        )
    }

    private func makeURL(for city: WeatherCity) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.open-meteo.com"
        components.path = "/v1/forecast"
        components.queryItems = [
            URLQueryItem(name: "latitude", value: "\(city.latitude)"),
            URLQueryItem(name: "longitude", value: "\(city.longitude)"),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m"),
            URLQueryItem(name: "timezone", value: "auto")
        ]

        guard let url = components.url else {
            throw WeatherServiceError.invalidURL
        }

        return url
    }
}

private struct OpenMeteoWeatherResponse: Decodable {
    let current: Current
    let currentUnits: CurrentUnits

    enum CodingKeys: String, CodingKey {
        case current
        case currentUnits = "current_units"
    }

    struct Current: Decodable {
        let time: String
        let temperature2m: Double
        let relativeHumidity2m: Double
        let apparentTemperature: Double
        let weatherCode: Int
        let windSpeed10m: Double

        enum CodingKeys: String, CodingKey {
            case time
            case temperature2m = "temperature_2m"
            case relativeHumidity2m = "relative_humidity_2m"
            case apparentTemperature = "apparent_temperature"
            case weatherCode = "weather_code"
            case windSpeed10m = "wind_speed_10m"
        }
    }

    struct CurrentUnits: Decodable {
        let temperature2m: String
        let windSpeed10m: String

        enum CodingKeys: String, CodingKey {
            case temperature2m = "temperature_2m"
            case windSpeed10m = "wind_speed_10m"
        }
    }
}
