//
//  RoomItem.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/23/26.
//
import Foundation
import SwiftData

@Model
final class RoomItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var category: RoomItemCategory
    var quantity: Int
    var note: String
    var createdAt: Date
    var room: Room?

    init(
        id: UUID = UUID(),
        title: String,
        category: RoomItemCategory,
        quantity: Int,
        note: String = "",
        createdAt: Date = Date(),
        room: Room? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.quantity = quantity
        self.note = note
        self.createdAt = createdAt
        self.room = room
    }
}

struct RoomItemDraft {
    var title: String
    var category: RoomItemCategory
    var quantity: Int
    var note: String
}

enum RoomItemCategory: String, CaseIterable, Codable, Identifiable {
    case furniture
    case lighting
    case electronics
    case decor
    case storage
    case other

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .furniture:
            "Furniture"
        case .lighting:
            "Lighting"
        case .electronics:
            "Electronics"
        case .decor:
            "Decor"
        case .storage:
            "Storage"
        case .other:
            "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .furniture:
            "sofa"
        case .lighting:
            "lamp.desk"
        case .electronics:
            "tv"
        case .decor:
            "paintpalette"
        case .storage:
            "archivebox"
        case .other:
            "shippingbox"
        }
    }
}
