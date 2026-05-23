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

    @State private var isShowingNewItemSheet = false
    @State private var itemToEdit: RoomItem?

    private var roomItemRepository: any RoomItemRepository {
        dependencies.makeRoomItemRepository(modelContext)
    }

    private var sortedItems: [RoomItem] {
        room.items.sorted { firstItem, secondItem in
            firstItem.createdAt < secondItem.createdAt
        }
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
                    isShowingNewItemSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Item")
            }
        }
        .sheet(isPresented: $isShowingNewItemSheet) {
            RoomItemForm(
                onSave: { draft in
                    createItem(from: draft)
                },
                onCancel: {
                    isShowingNewItemSheet = false
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(item: $itemToEdit) { item in
            RoomItemForm(
                itemToEdit: item,
                onSave: { draft in
                    updateItem(item, with: draft)
                },
                onCancel: {
                    itemToEdit = nil
                }
            )
            .presentationDetents([.medium])
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
                        isShowingNewItemSheet = true
                    }
                }
                .padding(.vertical, 18)
            } else {
                ForEach(sortedItems) { item in
                    RoomItemRow(item: item)
                        .swipeActions(edge: .leading) {
                            Button {
                                itemToEdit = item
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
                .onDelete { offsets in
                    let itemsToDelete = offsets.map { sortedItems[$0] }
                    deleteItems(itemsToDelete)
                }
            }
        }
    }

    private func createItem(from draft: RoomItemDraft) {
        roomItemRepository.createItem(in: room, from: draft)
        isShowingNewItemSheet = false
    }

    private func updateItem(_ item: RoomItem, with draft: RoomItemDraft) {
        roomItemRepository.updateItem(item, with: draft)
        itemToEdit = nil
    }

    private func deleteItems(_ items: [RoomItem]) {
        roomItemRepository.deleteItems(items)
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
