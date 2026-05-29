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

    @State private var viewModel = RoomsViewModel()

    var filteredRooms: [Room] {
        viewModel.filteredRooms(from: rooms)
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
            .searchable(text: searchTextBinding, prompt: "Search rooms")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    filterMenu

                    Button {
                        viewModel.isShowingNewRoomSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Create Room")
                }
            }
        }
        .onAppear {
            viewModel.configure(roomRepository: roomRepository)
        }
        .sheet(isPresented: isShowingNewRoomSheetBinding) {
            NewRoomForm(
                onSave: { draft in
                    viewModel.saveNewRoom(
                        draft: draft,
                        currentRoomCount: rooms.count,
                        isProUser: canCreateRoomsWithoutFreeLimit
                    )
                },
                onCancel: {
                    viewModel.isShowingNewRoomSheet = false
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(item: roomToEditBinding) { room in
            NewRoomForm(
                roomToEdit: room,
                onSave: { draft in
                    viewModel.saveEditedRoom(room, with: draft)
                },
                onCancel: {
                    viewModel.roomToEdit = nil
                }
            )
            .presentationDetents([.medium])
        }
        .fullScreenCover(isPresented: isShowingRoomLimitPaywallBinding) {
            PaywallView(
                title: "Unlock unlimited rooms",
                subtitle: "Free plans can create up to \(AppPlan.freeRoomLimit) rooms. Start Pro to save this room and keep building your home setup.",
                onStartTrial: {
                    viewModel.createPendingRoomAfterPurchase()
                },
                onContinueFree: {
                    viewModel.discardPendingRoom()
                }
            )
        }
        .alert("Could not update rooms", isPresented: errorAlertBinding) {
            Button("OK", role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

private extension RoomsTabView {
    var roomsList: some View {
        List {
            if subscriptionManager.shouldShowFreePlanMarketing {
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
                        viewModel.roomToEdit = room
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
                Image(systemName: viewModel.roomsRemaining(currentRoomCount: rooms.count) > 0 ? "house" : "lock")
                    .font(.headline)
                    .foregroundStyle(.blue)
                    .frame(width: 34, height: 34)
                    .background(Color.blue.opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.roomLimitTitle(currentRoomCount: rooms.count))
                        .font(.headline)

                    Text(viewModel.roomLimitSubtitle(currentRoomCount: rooms.count))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            ProgressView(value: viewModel.roomLimitProgress(currentRoomCount: rooms.count), total: 1)
                .tint(viewModel.roomLimitProgress(currentRoomCount: rooms.count) >= 1 ? .orange : .blue)

            Button {
                viewModel.showRoomLimitPaywall()
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
                viewModel.isShowingNewRoomSheet = true
            }
        }
    }

    var emptySearchView: some View {
        ContentUnavailableView {
            Label("No Results", systemImage: "magnifyingglass")
        } description: {
            Text("Try another search or room type.")
        } actions: {
            if viewModel.hasActiveFilters {
                Button("Clear Filters") {
                    viewModel.clearFilters()
                }
            }
        }
    }

    var filterMenu: some View {
        Menu {
            Picker("Room Type", selection: selectedRoomTypeBinding) {
                Text("All").tag(nil as RoomType?)

                ForEach(RoomType.allCases) { type in
                    Text(type.title).tag(type as RoomType?)
                }
            }
        } label: {
            Label("Filter", systemImage: viewModel.selectedRoomType == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
        }
        .accessibilityLabel("Filter Rooms")
    }

    func deleteRooms(_ roomsToDelete: [Room]) {
        viewModel.deleteRooms(roomsToDelete)
    }

    func itemCountTitle(for count: Int) -> String {
        count == 1 ? "1 item" : "\(count) items"
    }

    var canCreateRoomsWithoutFreeLimit: Bool {
        subscriptionManager.isProUser || !subscriptionManager.hasResolvedAccessLevel
    }

    var searchTextBinding: Binding<String> {
        Binding {
            viewModel.searchText
        } set: { searchText in
            viewModel.searchText = searchText
        }
    }

    var selectedRoomTypeBinding: Binding<RoomType?> {
        Binding {
            viewModel.selectedRoomType
        } set: { roomType in
            viewModel.selectedRoomType = roomType
        }
    }

    var isShowingNewRoomSheetBinding: Binding<Bool> {
        Binding {
            viewModel.isShowingNewRoomSheet
        } set: { isPresented in
            viewModel.isShowingNewRoomSheet = isPresented
        }
    }

    var roomToEditBinding: Binding<Room?> {
        Binding {
            viewModel.roomToEdit
        } set: { room in
            viewModel.roomToEdit = room
        }
    }

    var isShowingRoomLimitPaywallBinding: Binding<Bool> {
        Binding {
            viewModel.isShowingRoomLimitPaywall
        } set: { isPresented in
            viewModel.isShowingRoomLimitPaywall = isPresented
        }
    }

    var errorAlertBinding: Binding<Bool> {
        Binding {
            viewModel.errorMessage != nil
        } set: { isPresented in
            if !isPresented {
                viewModel.clearError()
            }
        }
    }
}
