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
    @Query(sort: \Room.createdAt) private var rooms: [Room]

    @State private var openModalSheet: Bool = false
    @State private var roomToEdit: Room?
    @State private var searchText: String = ""
    @State private var selectedRoomType: RoomType?

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
    }

    func saveNewRoom(draft: RoomDraft) {
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
}

private extension RoomsTabView {
    var roomsList: some View {
        List {
            ForEach(filteredRooms) { room in
                NavigationLink(destination: RoomView(room: room)) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(room.color.swiftUIColor)
                            .frame(width: 14, height: 14)

                        VStack(alignment: .leading) {
                            Text(room.title)
                            Text(room.type.title)
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
}
