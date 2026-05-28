//
//  RoomsViewModel.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/27/26.
//
import Foundation
import Observation

@MainActor
@Observable
final class RoomsViewModel {
    var isShowingNewRoomSheet = false
    var roomToEdit: Room?
    var searchText = ""
    var selectedRoomType: RoomType?
    var isShowingRoomLimitPaywall = false
    var errorMessage: String?

    @ObservationIgnored private var pendingRoomDraft: RoomDraft?
    @ObservationIgnored private var roomRepository: (any RoomRepository)?

    func configure(roomRepository: any RoomRepository) {
        self.roomRepository = roomRepository
    }

    func filteredRooms(from rooms: [Room]) -> [Room] {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return rooms.filter { room in
            let matchesSearch = trimmedSearchText.isEmpty
                || room.title.localizedCaseInsensitiveContains(trimmedSearchText)
                || room.type.title.localizedCaseInsensitiveContains(trimmedSearchText)

            let matchesType = selectedRoomType == nil || room.type == selectedRoomType

            return matchesSearch && matchesType
        }
    }

    var hasActiveFilters: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedRoomType != nil
    }

    func clearFilters() {
        searchText = ""
        selectedRoomType = nil
    }

    func saveNewRoom(draft: RoomDraft, currentRoomCount: Int, isProUser: Bool) {
        guard canCreateRoom(currentRoomCount: currentRoomCount, isProUser: isProUser) else {
            pendingRoomDraft = draft
            isShowingNewRoomSheet = false

            Task { @MainActor in
                await Task.yield()
                isShowingRoomLimitPaywall = true
            }

            return
        }

        do {
            try requireRoomRepository().createRoom(from: draft)
            isShowingNewRoomSheet = false
        } catch {
            showError(error)
        }
    }

    func saveEditedRoom(_ room: Room, with draft: RoomDraft) {
        do {
            try requireRoomRepository().updateRoom(room, with: draft)
            roomToEdit = nil
        } catch {
            showError(error)
        }
    }

    func deleteRooms(_ rooms: [Room]) {
        do {
            try requireRoomRepository().deleteRooms(rooms)
        } catch {
            showError(error)
        }
    }

    func showRoomLimitPaywall() {
        isShowingRoomLimitPaywall = true
    }

    func createPendingRoomAfterPurchase() {
        isShowingRoomLimitPaywall = false

        guard let pendingRoomDraft else {
            return
        }

        defer {
            self.pendingRoomDraft = nil
        }

        do {
            try requireRoomRepository().createRoom(from: pendingRoomDraft)
        } catch {
            showError(error)
        }
    }

    func discardPendingRoom() {
        pendingRoomDraft = nil
        isShowingRoomLimitPaywall = false
    }

    func clearError() {
        errorMessage = nil
    }

    func canCreateRoom(currentRoomCount: Int, isProUser: Bool) -> Bool {
        isProUser || currentRoomCount < AppPlan.freeRoomLimit
    }

    func roomsRemaining(currentRoomCount: Int) -> Int {
        max(0, AppPlan.freeRoomLimit - currentRoomCount)
    }

    func roomLimitProgress(currentRoomCount: Int) -> Double {
        Double(min(currentRoomCount, AppPlan.freeRoomLimit)) / Double(AppPlan.freeRoomLimit)
    }

    func roomLimitTitle(currentRoomCount: Int) -> String {
        let remaining = roomsRemaining(currentRoomCount: currentRoomCount)

        if remaining == 0 {
            return "Free room limit reached"
        }

        if remaining == 1 {
            return "1 free room left"
        }

        return "\(remaining) free rooms left"
    }

    func roomLimitSubtitle(currentRoomCount: Int) -> String {
        "\(currentRoomCount) of \(AppPlan.freeRoomLimit) rooms used on the free plan."
    }

    private func requireRoomRepository() throws -> any RoomRepository {
        guard let roomRepository else {
            throw RoomsViewModelError.missingRepository
        }

        return roomRepository
    }

    private func showError(_ error: Error) {
        errorMessage = error.localizedDescription
    }
}

private enum RoomsViewModelError: LocalizedError {
    case missingRepository

    var errorDescription: String? {
        switch self {
        case .missingRepository:
            "Room storage is not ready. Please try again."
        }
    }
}
