//
//  RoomItemForm.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/23/26.
//
import SwiftUI

struct RoomItemForm: View {
    @State private var title: String
    @State private var selectedCategory: RoomItemCategory
    @State private var quantity: Int
    @State private var note: String

    private let itemToEdit: RoomItem?
    let onSave: (RoomItemDraft) -> Void
    let onCancel: () -> Void

    init(
        itemToEdit: RoomItem? = nil,
        onSave: @escaping (RoomItemDraft) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.itemToEdit = itemToEdit
        self.onSave = onSave
        self.onCancel = onCancel
        self._title = State(initialValue: itemToEdit?.title ?? "")
        self._selectedCategory = State(initialValue: itemToEdit?.category ?? .furniture)
        self._quantity = State(initialValue: itemToEdit?.quantity ?? 1)
        self._note = State(initialValue: itemToEdit?.note ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Item name", text: $title)

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(RoomItemCategory.allCases) { category in
                            Label(category.title, systemImage: category.systemImage)
                                .tag(category)
                        }
                    }

                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                }

                Section("Note") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle(itemToEdit == nil ? "New Item" : "Edit Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(
                            RoomItemDraft(
                                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                category: selectedCategory,
                                quantity: quantity,
                                note: note.trimmingCharacters(in: .whitespacesAndNewlines)
                            )
                        )
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
        }
    }
}

#Preview {
    RoomItemForm(
        onSave: { _ in },
        onCancel: {}
    )
}
