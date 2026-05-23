//
//  Room.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/19/26.
//
import Foundation
import SwiftData

@Model
final class Room {
    @Attribute(.unique) var id: UUID
    var title: String
    var type: RoomType
    var color: RoomColor
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        type: RoomType,
        color: RoomColor,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.color = color
        self.createdAt = createdAt
    }
}

struct RoomDraft {
    var title: String
    var type: RoomType
    var color: RoomColor
}

enum RoomColor: String, CaseIterable, Codable, Identifiable {
    case red
    case green
    case yellow
    case blue
    case purple

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .red:
            "Red"
        case .green:
            "Green"
        case .yellow:
            "Yellow"
        case .blue:
            "Blue"
        case .purple:
            "Purple"
        }
    }
}

enum RoomType: String, CaseIterable, Codable, Identifiable {
    case bedroom
    case kitchen
    case livingRoom
    case bathroom
    case office

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .bedroom:
            "Bedroom"
        case .kitchen:
            "Kitchen"
        case .livingRoom:
            "Living room"
        case .bathroom:
            "Bathroom"
        case .office:
            "Office"
        }
    }
}

extension Room {
    static func sampleRooms() -> [Room] {
        [
            Room(title: "Main Bedroom", type: .bedroom, color: .red),
            Room(title: "Kitchen", type: .kitchen, color: .green),
            Room(title: "Living Room", type: .livingRoom, color: .yellow),
            Room(title: "Work Corner", type: .office, color: .blue)
        ]
    }
}
