//
//  RoomView.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/19/26.
//
import SwiftUI
import SwiftData

struct RoomView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDependencies) private var dependencies

    var room: Room

    @State private var viewModel = RoomDetailViewModel()

    private var roomItemRepository: any RoomItemRepository {
        dependencies.makeRoomItemRepository(modelContext)
    }

    private var sortedItems: [RoomItem] {
        viewModel.sortedItems(in: room)
    }

    var body: some View {
        List {
            roomSummarySection
            roomItemsSection
        }
        .navigationTitle(room.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.isShowingNewItemSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Item")
            }
        }
        .onAppear {
            viewModel.configure(roomItemRepository: roomItemRepository)
        }
        .sheet(isPresented: isShowingNewItemSheetBinding) {
            RoomItemForm(
                onSave: { draft in
                    viewModel.createItem(in: room, from: draft)
                },
                onCancel: {
                    viewModel.isShowingNewItemSheet = false
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(item: itemToEditBinding) { item in
            RoomItemForm(
                itemToEdit: item,
                onSave: { draft in
                    viewModel.updateItem(item, with: draft)
                },
                onCancel: {
                    viewModel.itemToEdit = nil
                }
            )
            .presentationDetents([.medium])
        }
        .alert("Could not update items", isPresented: errorAlertBinding) {
            Button("OK", role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var roomSummarySection: some View {
        Section {
            HStack(spacing: 14) {
                Circle()
                    .fill(room.color.swiftUIColor)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(room.type.title)
                        .font(.headline)

                    Text("\(sortedItems.count) items")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var roomItemsSection: some View {
        Section("Items") {
            if sortedItems.isEmpty {
                ContentUnavailableView {
                    Label("No Items", systemImage: "shippingbox")
                } description: {
                    Text("Add the first item in this room.")
                } actions: {
                    Button("Add Item") {
                        viewModel.isShowingNewItemSheet = true
                    }
                }
                .padding(.vertical, 18)
            } else {
                ForEach(sortedItems) { item in
                    RoomItemRow(item: item)
                        .swipeActions(edge: .leading) {
                            Button {
                                viewModel.itemToEdit = item
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
                .onDelete { offsets in
                    let itemsToDelete = offsets.map { sortedItems[$0] }
                    viewModel.deleteItems(itemsToDelete)
                }
            }
        }
    }

    private var isShowingNewItemSheetBinding: Binding<Bool> {
        Binding {
            viewModel.isShowingNewItemSheet
        } set: { isPresented in
            viewModel.isShowingNewItemSheet = isPresented
        }
    }

    private var itemToEditBinding: Binding<RoomItem?> {
        Binding {
            viewModel.itemToEdit
        } set: { item in
            viewModel.itemToEdit = item
        }
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding {
            viewModel.errorMessage != nil
        } set: { isPresented in
            if !isPresented {
                viewModel.clearError()
            }
        }
    }
}

private struct RoomItemRow: View {
    let item: RoomItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.category.systemImage)
                .font(.headline)
                .foregroundStyle(.blue)
                .frame(width: 34, height: 34)
                .background(Color.blue.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(item.title)
                        .font(.headline)

                    if item.quantity > 1 {
                        Text("x\(item.quantity)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(item.category.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !item.note.isEmpty {
                    Text(item.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
