//
//  PurchaseService.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/25/26.
//
import Foundation
import StoreKit

protocol PurchaseService: Sendable {
    func loadProducts(productIDs: Set<String>) async throws -> [Product]
    func purchase(_ product: Product) async throws -> PurchaseOutcome
    func currentEntitlementProductIDs() async -> Set<String>
    func restorePurchases() async throws
    func makeTransactionUpdatesTask(onUpdate: @escaping () async -> Void) -> Task<Void, Never>
}

enum PurchaseOutcome {
    case purchased
    case cancelled
    case pending
}

enum PurchaseServiceError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            "The App Store could not verify this transaction."
        }
    }
}
