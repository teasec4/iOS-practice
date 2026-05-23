//
//  WeatherTabView.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/22/26.
//
import SwiftUI

struct WeatherTabView: View {
    @State private var viewModel: WeatherViewModel

    init(weatherService: any WeatherService = OpenMeteoWeatherService()) {
        self._viewModel = State(initialValue: WeatherViewModel(weatherService: weatherService))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("City", selection: selectedCityBinding) {
                        ForEach(WeatherCity.availableCities) { city in
                            Text(city.name).tag(city)
                        }
                    }
                }

                switch viewModel.state {
                case .idle:
                    EmptyView()
                case .loading:
                    loadingSection
                case .loaded(let weather):
                    currentWeatherSection(weather)
                case .failed(let errorMessage):
                    errorSection(errorMessage)
                }
            }
            .refreshable {
                await viewModel.loadWeather()
            }
            .navigationTitle("Weather")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await viewModel.loadWeather()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                    .accessibilityLabel("Reload Weather")
                }
            }
        }
        .task {
            await viewModel.loadWeatherIfNeeded()
        }
        .onChange(of: viewModel.selectedCity) {
            Task {
                await viewModel.loadWeather()
            }
        }
    }

    private var selectedCityBinding: Binding<WeatherCity> {
        Binding {
            viewModel.selectedCity
        } set: { city in
            viewModel.selectedCity = city
        }
    }

    private var loadingSection: some View {
        Section {
            HStack(spacing: 12) {
                ProgressView()
                Text("Loading weather")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func errorSection(_ message: String) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Label("Could not load weather", systemImage: "exclamationmark.triangle")
                    .font(.headline)

                Text(message)
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Button {
                    Task {
                        await viewModel.loadWeather()
                    }
                } label: {
                    Label("Retry", systemImage: "arrow.clockwise")
                }
                .disabled(viewModel.isLoading)
            }
            .padding(.vertical, 6)
        }
    }

    private func currentWeatherSection(_ weather: CurrentWeather) -> some View {
        Section("Current") {
            HStack(spacing: 12) {
                Image(systemName: weather.symbolName)
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 32)

                VStack(alignment: .leading) {
                    Text(weather.conditionTitle)
                    Text(weather.city.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(formattedTemperature(weather.temperature, unit: weather.temperatureUnit))
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            WeatherMetricRow(
                title: "Feels like",
                value: formattedTemperature(weather.apparentTemperature, unit: weather.temperatureUnit)
            )
            WeatherMetricRow(title: "Humidity", value: "\(Int(weather.humidity))%")
            WeatherMetricRow(
                title: "Wind",
                value: "\(formattedNumber(weather.windSpeed)) \(weather.windSpeedUnit)"
            )
            WeatherMetricRow(title: "Updated", value: weather.updatedAt)
        }
    }

    private func formattedTemperature(_ value: Double, unit: String) -> String {
        "\(formattedNumber(value))\(unit)"
    }

    private func formattedNumber(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1)))
    }
}

private struct WeatherMetricRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
