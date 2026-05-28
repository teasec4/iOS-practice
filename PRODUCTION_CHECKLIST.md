# Production Checklist

## Critical

### Tests

Add unit tests for:

- `RoomsViewModel`
- `RoomDetailViewModel`
- `SubscriptionManager`
- `WeatherViewModel`
- SwiftData repositories with an in-memory `ModelContainer`

Add UI tests for the main monetization flow:

- onboarding
- paywall
- free plan limit
- Pro purchase/unlock behavior

### StoreKit Production Setup

Configure real subscription products in App Store Connect:

- subscription group
- product id
- price
- free trial
- localization
- App Review approval

For subscriptions, Apple expects a clear restore mechanism and clear subscription terms. The app already has restore/manage subscription entry points, but the flow still needs an App Review pass.

Useful Apple docs:

- Apple Subscriptions
- App Review Guidelines

### Privacy / Legal

Add production-ready legal and privacy materials:

- Privacy Policy
- Terms of Use or EULA
- App Privacy details in App Store Connect

Even if the app stores very little data, the App Store listing must honestly describe what data is collected, why it is collected, and whether it is linked to the user.

Useful Apple docs:

- App Privacy Details

### SwiftData Migration Strategy

Current models are simple, but production releases need a migration plan for future changes to:

- `Room`
- `RoomItem`
- `UserProfile`

Without a migration strategy, a future app update can break local user data.

### Observability

Add production observability:

- crash reports
- privacy-safe analytics
- logging for persistence errors
- logging for purchase errors
- logging for API errors

Without this, it will be hard to understand what is actually failing for real users after release.
