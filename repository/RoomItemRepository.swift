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
    func createItem(in room: Room, from draft: RoomItemDraft) throws
    func updateItem(_ item: RoomItem, with draft: RoomItemDraft) throws
    func deleteItems(_ items: [RoomItem]) throws
}

@MainActor
struct SwiftDataRoomItemRepository: RoomItemRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createItem(in room: Room, from draft: RoomItemDraft) throws {
        let item = RoomItem(
            title: draft.title,
            category: draft.category,
            quantity: draft.quantity,
            note: draft.note
        )

        modelContext.insert(item)
        room.items.append(item)
        try save()
    }

    func updateItem(_ item: RoomItem, with draft: RoomItemDraft) throws {
        item.title = draft.title
        item.category = draft.category
        item.quantity = draft.quantity
        item.note = draft.note
        try save()
    }

    func deleteItems(_ items: [RoomItem]) throws {
        for item in items {
            modelContext.delete(item)
        }

        try save()
    }

    private func save() throws {
        try modelContext.save()
    }
}
