//
//  PaywallView.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/24/26.
//
import SwiftUI

struct PaywallView: View {
    let title: String
    let subtitle: String
    let onStartTrial: () -> Void
    let onContinueFree: () -> Void

    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var isLoadingPurchase = false

    init(
        title: String = "Your room profile is ready",
        subtitle: String = "Unlock a personalized plan and smarter recommendations for every room.",
        onStartTrial: @escaping () -> Void,
        onContinueFree: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.onStartTrial = onStartTrial
        self.onContinueFree = onContinueFree
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()

                Button {
                    onContinueFree()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .accessibilityLabel("Continue with free version")
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 14) {
                        Image(systemName: "sparkles.rectangle.stack")
                            .font(.system(size: 52, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 104, height: 104)
                            .background(.blue, in: Circle())

                        VStack(spacing: 8) {
                            Text(title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)

                            Text(subtitle)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        PaywallBenefitRow(
                            systemImage: "wand.and.sparkles",
                            title: "Personalized room plan",
                            subtitle: "Get focused next steps based on your answers."
                        )
                        PaywallBenefitRow(
                            systemImage: "square.grid.2x2",
                            title: "Unlimited rooms and items",
                            subtitle: "Track everything without free-plan limits."
                        )
                        PaywallBenefitRow(
                            systemImage: "chart.bar.xaxis",
                            title: "Advanced home analytics",
                            subtitle: "See what is improving and what needs attention."
                        )
                    }

                    VStack(spacing: 10) {
                        PlanComparisonRow(title: "Rooms", freeValue: "Basic", proValue: "Unlimited")
                        PlanComparisonRow(title: "Items", freeValue: "Basic list", proValue: "Smart tracking")
                        PlanComparisonRow(title: "Analysis", freeValue: "Preview", proValue: "Personalized")
                        PlanComparisonRow(title: "Recommendations", freeValue: "Manual", proValue: "Guided")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
            }

            VStack(spacing: 12) {
                Button {
                    Task {
                        isLoadingPurchase = true
                        defer { isLoadingPurchase = false }

                        let didPurchase = await subscriptionManager.purchasePro()

                        if didPurchase {
                            onStartTrial()
                        }
                    }
                } label: {
                    Label(primaryButtonTitle, systemImage: "crown")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isLoadingPurchase || !subscriptionManager.canStartPurchase)

                Text(priceSubtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if let errorMessage = subscriptionManager.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if subscriptionManager.errorMessage != nil {
                    Button {
                        Task {
                            await subscriptionManager.loadProducts()
                        }
                    } label: {
                        Label("Retry loading subscription", systemImage: "arrow.clockwise")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                Button {
                    onContinueFree()
                } label: {
                    Text("Continue with free version")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .background(.regularMaterial)
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await subscriptionManager.loadProducts()
        }
    }

    private var primaryButtonTitle: String {
        if isLoadingPurchase {
            return "Starting trial"
        }

        if subscriptionManager.isLoadingProducts {
            return "Loading subscription"
        }

        return "Start 7-day free trial"
    }

    private var priceSubtitle: String {
        if subscriptionManager.proProduct == nil {
            return "7 days free, then $9/week. Auto-renews. Cancel anytime."
        }

        return "7 days free, then \(subscriptionManager.proPriceTitle). Auto-renews. Cancel anytime."
    }
}

private struct PaywallBenefitRow: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)
                .background(Color.blue.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct PlanComparisonRow: View {
    let title: String
    let freeValue: String
    let proValue: String

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(freeValue)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 88, alignment: .leading)

            Label(proValue, systemImage: "checkmark.circle.fill")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
                .frame(width: 116, alignment: .leading)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    PaywallView(
        onStartTrial: {},
        onContinueFree: {}
    )
    .environment(SubscriptionManager.preview())
}
