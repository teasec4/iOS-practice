//
//  SettingsTabView.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/23/26.
//
import SwiftUI
import StoreKit

struct SettingsTabView: View {
    let onResetOnboarding: () -> Void

    @AppStorage("userProfileData") private var userProfileData = ""
    @AppStorage("selectedAppTheme") private var selectedAppTheme = AppTheme.system.rawValue
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var isShowingSettingsPaywall = false
    @State private var isShowingManageSubscriptions = false

    private var userProfile: UserProfile? {
        UserProfile.decoded(from: userProfileData)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Plan") {
                    HStack {
                        Label(planTitle, systemImage: planSystemImage)
                        Spacer()

                        if subscriptionManager.hasResolvedAccessLevel {
                            Text(planStatusTitle)
                                .foregroundStyle(.secondary)
                        } else {
                            ProgressView()
                                .controlSize(.small)
                        }
                    }
                }

                if let userProfile {
                    profileSection(userProfile)
                }

                if subscriptionManager.shouldShowFreePlanMarketing {
                    premiumTeaserSection
                }

                appearanceSection

                Section("Purchases") {
                    Button {
                        isShowingManageSubscriptions = true
                    } label: {
                        Label("Manage Subscription", systemImage: "creditcard")
                    }

                    Button {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    } label: {
                        Label(subscriptionManager.isRestoring ? "Restoring purchases" : "Restore Purchases", systemImage: "arrow.clockwise")
                    }
                    .disabled(subscriptionManager.isRestoring)

                    if let errorMessage = subscriptionManager.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Developer") {
                    Button {
                        onResetOnboarding()
                    } label: {
                        Label("Reset onboarding and profile", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .fullScreenCover(isPresented: $isShowingSettingsPaywall) {
            PaywallView(
                title: "Upgrade your room planning",
                subtitle: "Unlock unlimited rooms, personalized analysis, and smarter recommendations for your setup.",
                onStartTrial: {
                    isShowingSettingsPaywall = false
                },
                onContinueFree: {
                    isShowingSettingsPaywall = false
                }
            )
        }
        .manageSubscriptionsSheet(isPresented: $isShowingManageSubscriptions)
        .onChange(of: isShowingManageSubscriptions) {
            guard !isShowingManageSubscriptions else {
                return
            }

            Task {
                await subscriptionManager.refreshEntitlements()
            }
        }
    }
}

private extension SettingsTabView {
    var planTitle: String {
        switch subscriptionManager.accessLevel {
        case .unknown:
            "Checking"
        case .free:
            "Free"
        case .pro:
            "Pro"
        }
    }

    var planStatusTitle: String {
        switch subscriptionManager.accessLevel {
        case .unknown:
            "Syncing"
        case .free:
            "Free version"
        case .pro:
            "Active"
        }
    }

    var planSystemImage: String {
        switch subscriptionManager.accessLevel {
        case .unknown:
            "clock"
        case .free:
            "person"
        case .pro:
            "crown"
        }
    }

    func profileSection(_ profile: UserProfile) -> some View {
        Section("Personal Summary") {
            VStack(alignment: .leading, spacing: 8) {
                Label("Profile focus", systemImage: "person.text.rectangle")
                    .font(.headline)

                Text(profile.headline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(profile.recommendation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)

            ForEach(profile.summaryItems) { item in
                ProfileSummaryRow(item: item)
            }
        }
    }

    var premiumTeaserSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Label("Make this profile actionable", systemImage: "crown")
                    .font(.headline)

                Text("Pro turns your profile into unlimited rooms, smarter item tracking, and guided recommendations.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button {
                    isShowingSettingsPaywall = true
                } label: {
                    Label("Start 7-day free trial", systemImage: "sparkles")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding(.vertical, 6)
        }
    }

    var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $selectedAppTheme) {
                ForEach(AppTheme.allCases) { theme in
                    Label(theme.title, systemImage: theme.systemImage)
                        .tag(theme.rawValue)
                }
            }
        }
    }
}

private struct ProfileSummaryRow: View {
    let item: UserProfileSummaryItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.systemImage)
                .font(.subheadline)
                .foregroundStyle(.blue)
                .frame(width: 28, height: 28)
                .background(Color.blue.opacity(0.12), in: Circle())

            Text(item.title)

            Spacer()

            Text(item.value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    SettingsTabView {}
        .environment(SubscriptionManager.preview())
}
