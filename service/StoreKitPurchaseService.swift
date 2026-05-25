//
//  StoreKitPurchaseService.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/25/26.
//
import Foundation
import StoreKit

struct StoreKitPurchaseService: PurchaseService {
    func loadProducts(productIDs: Set<String>) async throws -> [Product] {
        let requestedProductIDs = Array(productIDs)
        let products = try await Product.products(for: requestedProductIDs)

        #if DEBUG
        print("STOREKIT requested product IDs:", requestedProductIDs)
        print("STOREKIT returned product IDs:", products.map(\.id))

        if products.isEmpty {
            let hasBundledConfiguration = Bundle.main.url(forResource: "BackToGame", withExtension: "storekit") != nil
            print("STOREKIT bundled configuration exists:", hasBundledConfiguration)
            print("STOREKIT bundle identifier:", Bundle.main.bundleIdentifier ?? "unknown")
        }
        #endif

        return products
    }

    func purchase(_ product: Product) async throws -> PurchaseOutcome {
        let result = try await product.purchase()

        switch result {
        case .success(let verificationResult):
            let transaction = try verified(verificationResult)
            await transaction.finish()
            return .purchased
        case .userCancelled:
            return .cancelled
        case .pending:
            return .pending
        @unknown default:
            return .cancelled
        }
    }

    func currentEntitlementProductIDs() async -> Set<String> {
        var productIDs = Set<String>()

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? verified(result),
                  transaction.revocationDate == nil,
                  isTransactionActive(transaction) else {
                continue
            }

            productIDs.insert(transaction.productID)
        }

        return productIDs
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
    }

    func makeTransactionUpdatesTask(onUpdate: @escaping () async -> Void) -> Task<Void, Never> {
        Task {
            for await result in Transaction.updates {
                guard let transaction = try? verified(result) else {
                    continue
                }

                await transaction.finish()
                await onUpdate()
            }
        }
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw PurchaseServiceError.failedVerification
        }
    }

    private func isTransactionActive(_ transaction: Transaction) -> Bool {
        guard let expirationDate = transaction.expirationDate else {
            return true
        }

        return expirationDate > Date()
    }
}
