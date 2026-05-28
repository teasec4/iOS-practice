//
//  RoomDetailViewModel.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/27/26.
//
import Foundation
import Observation

@MainActor
@Observable
final class RoomDetailViewModel {
    var isShowingNewItemSheet = false
    var itemToEdit: RoomItem?
    var errorMessage: String?

    @ObservationIgnored private var roomItemRepository: (any RoomItemRepository)?

    func configure(roomItemRepository: any RoomItemRepository) {
        self.roomItemRepository = roomItemRepository
    }

    func sortedItems(in room: Room) -> [RoomItem] {
        room.items.sorted { firstItem, secondItem in
            firstItem.createdAt < secondItem.createdAt
        }
    }

    func createItem(in room: Room, from draft: RoomItemDraft) {
        do {
            try requireRoomItemRepository().createItem(in: room, from: draft)
            isShowingNewItemSheet = false
        } catch {
            showError(error)
        }
    }

    func updateItem(_ item: RoomItem, with draft: RoomItemDraft) {
        do {
            try requireRoomItemRepository().updateItem(item, with: draft)
            itemToEdit = nil
        } catch {
            showError(error)
        }
    }

    func deleteItems(_ items: [RoomItem]) {
        do {
            try requireRoomItemRepository().deleteItems(items)
        } catch {
            showError(error)
        }
    }

    func clearError() {
        errorMessage = nil
    }

    private func requireRoomItemRepository() throws -> any RoomItemRepository {
        guard let roomItemRepository else {
            throw RoomDetailViewModelError.missingRepository
        }

        return roomItemRepository
    }

    private func showError(_ error: Error) {
        errorMessage = error.localizedDescription
    }
}

private enum RoomDetailViewModelError: LocalizedError {
    case missingRepository

    var errorDescription: String? {
        switch self {
        case .missingRepository:
            "Room item storage is not ready. Please try again."
        }
    }
}
