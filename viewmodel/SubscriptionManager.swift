//
//  SubscriptionManager.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/25/26.
//
import Foundation
import Observation
import StoreKit

enum SubscriptionAccessLevel {
    case free
    case pro
}

enum SubscriptionCatalogState {
    case idle
    case loading
    case ready
    case unavailable(String)
    case failed(String)

    var isLoading: Bool {
        if case .loading = self {
            return true
        }

        return false
    }

    var message: String? {
        switch self {
        case .unavailable(let message), .failed(let message):
            return message
        case .idle, .loading, .ready:
            return nil
        }
    }
}

enum SubscriptionOperationState {
    case idle
    case purchasing
    case restoring
    case pending(String)
    case failed(String)

    var isPurchasing: Bool {
        if case .purchasing = self {
            return true
        }

        return false
    }

    var isRestoring: Bool {
        if case .restoring = self {
            return true
        }

        return false
    }

    var message: String? {
        switch self {
        case .pending(let message), .failed(let message):
            return message
        case .idle, .purchasing, .restoring:
            return nil
        }
    }
}

@MainActor
@Observable
final class SubscriptionManager {
    private(set) var products: [Product] = []
    private(set) var accessLevel: SubscriptionAccessLevel = .free
    private(set) var catalogState: SubscriptionCatalogState = .idle
    private(set) var operationState: SubscriptionOperationState = .idle

    @ObservationIgnored private let purchaseService: any PurchaseService
    @ObservationIgnored private var transactionUpdatesTask: Task<Void, Never>?
    @ObservationIgnored private var hasStarted = false

    init(purchaseService: any PurchaseService) {
        self.purchaseService = purchaseService
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    var proProduct: Product? {
        products.first { product in
            product.id == AppPlan.proWeeklyProductID
        }
    }

    var proPriceTitle: String? {
        guard let proProduct else {
            return nil
        }

        return "\(proProduct.displayPrice)/\(subscriptionPeriodTitle(for: proProduct))"
    }

    var isProUser: Bool {
        accessLevel == .pro
    }

    var isLoadingProducts: Bool {
        catalogState.isLoading
    }

    var isPurchasing: Bool {
        operationState.isPurchasing
    }

    var isRestoring: Bool {
        operationState.isRestoring
    }

    var errorMessage: String? {
        operationState.message ?? catalogState.message
    }

    var canStartPurchase: Bool {
        proProduct != nil && !isLoadingProducts && !isPurchasing
    }

    func start() async {
        guard !hasStarted else {
            return
        }

        hasStarted = true
        transactionUpdatesTask = purchaseService.makeTransactionUpdatesTask { [weak self] in
            await self?.refreshEntitlements()
        }

        await loadProducts()
        await refreshEntitlements()
    }

    func loadProducts() async {
        guard !isLoadingProducts else {
            return
        }

        catalogState = .loading

        do {
            products = try await purchaseService.loadProducts(productIDs: AppPlan.proProductIDs)
                .sorted { firstProduct, secondProduct in
                    firstProduct.id < secondProduct.id
                }

            if products.isEmpty {
                catalogState = .unavailable(unavailableSubscriptionMessage)
            } else {
                catalogState = .ready
            }
        } catch {
            catalogState = .failed(error.localizedDescription)
        }
    }

    func purchasePro() async -> Bool {
        guard !isPurchasing else {
            return false
        }

        operationState = .purchasing
        defer {
            if operationState.isPurchasing {
                operationState = .idle
            }
        }

        if proProduct == nil {
            await loadProducts()
        }

        guard let proProduct else {
            catalogState = .unavailable(unavailableSubscriptionMessage)
            return false
        }

        do {
            let outcome = try await purchaseService.purchase(proProduct)
            await refreshEntitlements()

            switch outcome {
            case .purchased:
                accessLevel = .pro
                operationState = .idle
                return true
            case .cancelled:
                operationState = .idle
                return false
            case .pending:
                operationState = .pending("Purchase is pending approval.")
                return false
            }
        } catch {
            operationState = .failed(error.localizedDescription)
            return false
        }
    }

    func restorePurchases() async {
        guard !isRestoring else {
            return
        }

        operationState = .restoring
        defer {
            if operationState.isRestoring {
                operationState = .idle
            }
        }

        do {
            try await purchaseService.restorePurchases()
            await refreshEntitlements()
            operationState = .idle
        } catch {
            operationState = .failed(error.localizedDescription)
        }
    }

    func refreshEntitlements() async {
        let entitlementProductIDs = await purchaseService.currentEntitlementProductIDs()
        let hasStoreKitPro = !AppPlan.proProductIDs.isDisjoint(with: entitlementProductIDs)
        accessLevel = hasStoreKitPro ? .pro : .free
    }

    private func subscriptionPeriodTitle(for product: Product) -> String {
        guard let period = product.subscription?.subscriptionPeriod else {
            return "week"
        }

        let unitTitle: String

        switch period.unit {
        case .day:
            unitTitle = "day"
        case .week:
            unitTitle = "week"
        case .month:
            unitTitle = "month"
        case .year:
            unitTitle = "year"
        @unknown default:
            unitTitle = "period"
        }

        if period.value == 1 {
            return unitTitle
        }

        return "\(period.value) \(unitTitle)s"
    }

    private var unavailableSubscriptionMessage: String {
        "No StoreKit product found for \(AppPlan.proWeeklyProductID). Check that the selected StoreKit configuration contains this product."
    }

    static func preview(isProUser: Bool = false) -> SubscriptionManager {
        let manager = SubscriptionManager(purchaseService: PreviewPurchaseService())
        manager.accessLevel = isProUser ? .pro : .free
        return manager
    }
}
