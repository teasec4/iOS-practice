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
    func createRoom(from draft: RoomDraft)
    func updateRoom(_ room: Room, with draft: RoomDraft)
    func deleteRooms(_ rooms: [Room])
    func seedSampleRoomsIfNeeded(existingRooms: [Room])
}

@MainActor
struct SwiftDataRoomRepository: RoomRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createRoom(from draft: RoomDraft) {
        let room = Room(title: draft.title, type: draft.type, color: draft.color)
        modelContext.insert(room)
        save()
    }

    func updateRoom(_ room: Room, with draft: RoomDraft) {
        room.title = draft.title
        room.type = draft.type
        room.color = draft.color
        save()
    }

    func deleteRooms(_ rooms: [Room]) {
        for room in rooms {
            modelContext.delete(room)
        }

        save()
    }

    func seedSampleRoomsIfNeeded(existingRooms: [Room]) {
        guard existingRooms.isEmpty else {
            return
        }

        for room in Room.sampleRooms() {
            modelContext.insert(room)
        }

        save()
    }

    private func save() {
        try? modelContext.save()
    }
}
