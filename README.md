# BackToGame

![Swift](https://img.shields.io/badge/Swift-5-orange)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue)
![SwiftData](https://img.shields.io/badge/Persistence-SwiftData-purple)
![iOS](https://img.shields.io/badge/Platform-iOS-lightgrey)
![Status](https://img.shields.io/badge/Status-Practice%20Project-brightgreen)

BackToGame is a small iOS practice project for refreshing Swift, SwiftUI, navigation, state management, persistence, dependency injection, API services, onboarding, and subscription-style flows.

## Features

- SwiftUI `TabView` app structure
- Room list with search, filters, empty states, and CRUD
- Room detail screen with related room items
- SwiftData models and relationships
- Repository layer for room and item mutations
- Weather API example through a service protocol
- App-level dependency container
- Onboarding survey with animated analysis progress
- Mock paywall flow with free trial and free-plan fallback
- Free-plan room limit with upgrade trigger

## Architecture Practice

The project intentionally keeps the code small, but touches common production patterns:

- `RootView` controls onboarding vs main app routing
- `AppDependencies` stores app services and repository factories
- `RoomRepository` and `RoomItemRepository` isolate SwiftData mutations
- `WeatherService` shows protocol-based API abstraction
- `PaywallView` is reusable for onboarding and feature-limit upsells

## Run

Open the Xcode project one level above this folder:

```bash
open ../backtogame.xcodeproj
```

Then run the `backtogame` scheme on an iOS simulator.

## Notes

This is a learning project. The subscription flow currently uses mock state through `AppStorage`; a real App Store subscription would need StoreKit integration, product loading, purchase handling, entitlement updates, and restore purchases.
