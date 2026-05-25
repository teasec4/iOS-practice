//
//  PreviewPurchaseService.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/25/26.
//
import Foundation
import StoreKit

struct PreviewPurchaseService: PurchaseService {
    func loadProducts(productIDs: Set<String>) async throws -> [Product] {
        []
    }

    func purchase(_ product: Product) async throws -> PurchaseOutcome {
        .purchased
    }

    func currentEntitlementProductIDs() async -> Set<String> {
        []
    }

    func restorePurchases() async throws {
    }

    func makeTransactionUpdatesTask(onUpdate: @escaping () async -> Void) -> Task<Void, Never> {
        Task { }
    }
}
