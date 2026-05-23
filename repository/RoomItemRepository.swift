//
//  RoomItemRepository.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/23/26.
//
import Foundation
import SwiftData

@MainActor
protocol RoomItemRepository {
    func createItem(in room: Room, from draft: RoomItemDraft)
    func updateItem(_ item: RoomItem, with draft: RoomItemDraft)
    func deleteItems(_ items: [RoomItem])
}

@MainActor
struct SwiftDataRoomItemRepository: RoomItemRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createItem(in room: Room, from draft: RoomItemDraft) {
        let item = RoomItem(
            title: draft.title,
            category: draft.category,
            quantity: draft.quantity,
            note: draft.note
        )

        modelContext.insert(item)
        room.items.append(item)
        save()
    }

    func updateItem(_ item: RoomItem, with draft: RoomItemDraft) {
        item.title = draft.title
        item.category = draft.category
        item.quantity = draft.quantity
        item.note = draft.note
        save()
    }

    func deleteItems(_ items: [RoomItem]) {
        for item in items {
            modelContext.delete(item)
        }

        save()
    }

    private func save() {
        try? modelContext.save()
    }
}
