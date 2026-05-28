//
//  RoomRepository.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/22/26.
//
import Foundation
import SwiftData

@MainActor
protocol RoomRepository {
    func createRoom(from draft: RoomDraft) throws
    func updateRoom(_ room: Room, with draft: RoomDraft) throws
    func deleteRooms(_ rooms: [Room]) throws
    func seedSampleRoomsIfNeeded(existingRooms: [Room]) throws
}

@MainActor
struct SwiftDataRoomRepository: RoomRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createRoom(from draft: RoomDraft) throws {
        let room = Room(title: draft.title, type: draft.type, color: draft.color)
        modelContext.insert(room)
        try save()
    }

    func updateRoom(_ room: Room, with draft: RoomDraft) throws {
        room.title = draft.title
        room.type = draft.type
        room.color = draft.color
        try save()
    }

    func deleteRooms(_ rooms: [Room]) throws {
        for room in rooms {
            modelContext.delete(room)
        }

        try save()
    }

    func seedSampleRoomsIfNeeded(existingRooms: [Room]) throws {
        guard existingRooms.isEmpty else {
            return
        }

        for room in Room.sampleRooms() {
            modelContext.insert(room)
        }

        try save()
    }

    private func save() throws {
        try modelContext.save()
    }
}
