//
//  RoomsTabView.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/22/26.
//
import SwiftUI
import SwiftData

struct RoomsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDependencies) private var dependencies
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Query(sort: \Room.createdAt) private var rooms: [Room]

    @State private var openModalSheet: Bool = false
    @State private var roomToEdit: Room?
    @State private var searchText: String = ""
    @State private var selectedRoomType: RoomType?
    @State private var pendingRoomDraft: RoomDraft?
    @State private var isShowingRoomLimitPaywall = false

    var filteredRooms: [Room] {
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

    private var roomRepository: any RoomRepository {
        dependencies.makeRoomRepository(modelContext)
    }

    var body: some View {
        NavigationStack {
            Group {
                if rooms.isEmpty {
                    emptyRoomsView
                } else if filteredRooms.isEmpty {
                    emptySearchView
                } else {
                    roomsList
                }
            }
            .navigationTitle("Rooms")
            .searchable(text: $searchText, prompt: "Search rooms")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    filterMenu

                    Button {
                        openModalSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Create Room")
                }
            }
        }
        .sheet(isPresented: $openModalSheet) {
            NewRoomForm(
                onSave: { draft in
                    saveNewRoom(draft: draft)
                },
                onCancel: {
                    openModalSheet = false
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(item: $roomToEdit) { room in
            NewRoomForm(
                roomToEdit: room,
                onSave: { draft in
                    saveEditedRoom(room: room, draft: draft)
                },
                onCancel: {
                    roomToEdit = nil
                }
            )
            .presentationDetents([.medium])
        }
        .fullScreenCover(isPresented: $isShowingRoomLimitPaywall) {
            PaywallView(
                title: "Unlock unlimited rooms",
                subtitle: "Free plans can create up to \(AppPlan.freeRoomLimit) rooms. Start Pro to save this room and keep building your home setup.",
                onStartTrial: {
                    createPendingRoomAfterPurchase()
                },
                onContinueFree: {
                    discardPendingRoom()
                }
            )
        }
    }

    func saveNewRoom(draft: RoomDraft) {
        guard canCreateRoomWithoutPaywall else {
            pendingRoomDraft = draft
            openModalSheet = false

            Task { @MainActor in
                await Task.yield()
                isShowingRoomLimitPaywall = true
            }

            return
        }

        roomRepository.createRoom(from: draft)
        openModalSheet = false
    }

    func saveEditedRoom(room: Room, draft: RoomDraft) {
        roomRepository.updateRoom(room, with: draft)
        roomToEdit = nil
    }

    func clearFilters() {
        searchText = ""
        selectedRoomType = nil
    }

    var canCreateRoomWithoutPaywall: Bool {
        subscriptionManager.isProUser || rooms.count < AppPlan.freeRoomLimit
    }

    func createPendingRoomAfterPurchase() {
        isShowingRoomLimitPaywall = false

        if let pendingRoomDraft {
            roomRepository.createRoom(from: pendingRoomDraft)
        }

        pendingRoomDraft = nil
    }

    func discardPendingRoom() {
        pendingRoomDraft = nil
        isShowingRoomLimitPaywall = false
    }
}

private extension RoomsTabView {
    var roomsList: some View {
        List {
            if !subscriptionManager.isProUser {
                Section {
                    freePlanLimitBanner
                }
            }

            ForEach(filteredRooms) { room in
                NavigationLink(destination: RoomView(room: room)) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(room.color.swiftUIColor)
                            .frame(width: 14, height: 14)

                        VStack(alignment: .leading) {
                            Text(room.title)

                            HStack(spacing: 6) {
                                Text(room.type.title)
                                Text(itemCountTitle(for: room.items.count))
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        roomToEdit = room
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
            .onDelete { offsets in
                let roomsToDelete = offsets.map { filteredRooms[$0] }
                deleteRooms(roomsToDelete)
            }
        }
    }

    var freePlanLimitBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: roomsRemaining > 0 ? "house" : "lock")
                    .font(.headline)
                    .foregroundStyle(.blue)
                    .frame(width: 34, height: 34)
                    .background(Color.blue.opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(roomLimitTitle)
                        .font(.headline)

                    Text(roomLimitSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            ProgressView(value: roomLimitProgress, total: 1)
                .tint(roomLimitProgress >= 1 ? .orange : .blue)

            Button {
                isShowingRoomLimitPaywall = true
            } label: {
                Label("Unlock unlimited rooms", systemImage: "crown")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.vertical, 6)
    }

    var emptyRoomsView: some View {
        ContentUnavailableView {
            Label("No Rooms", systemImage: "house")
        } description: {
            Text("Create your first room.")
        } actions: {
            Button("Create Room") {
                openModalSheet = true
            }
        }
    }

    var emptySearchView: some View {
        ContentUnavailableView {
            Label("No Results", systemImage: "magnifyingglass")
        } description: {
            Text("Try another search or room type.")
        } actions: {
            if hasActiveFilters {
                Button("Clear Filters") {
                    clearFilters()
                }
            }
        }
    }

    var filterMenu: some View {
        Menu {
            Picker("Room Type", selection: $selectedRoomType) {
                Text("All").tag(nil as RoomType?)

                ForEach(RoomType.allCases) { type in
                    Text(type.title).tag(type as RoomType?)
                }
            }
        } label: {
            Label("Filter", systemImage: selectedRoomType == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
        }
        .accessibilityLabel("Filter Rooms")
    }

    func deleteRooms(_ roomsToDelete: [Room]) {
        roomRepository.deleteRooms(roomsToDelete)
    }

    func itemCountTitle(for count: Int) -> String {
        count == 1 ? "1 item" : "\(count) items"
    }

    var roomsRemaining: Int {
        max(0, AppPlan.freeRoomLimit - rooms.count)
    }

    var roomLimitProgress: Double {
        Double(min(rooms.count, AppPlan.freeRoomLimit)) / Double(AppPlan.freeRoomLimit)
    }

    var roomLimitTitle: String {
        if roomsRemaining == 0 {
            return "Free room limit reached"
        }

        if roomsRemaining == 1 {
            return "1 free room left"
        }

        return "\(roomsRemaining) free rooms left"
    }

    var roomLimitSubtitle: String {
        "\(rooms.count) of \(AppPlan.freeRoomLimit) rooms used on the free plan."
    }
}
