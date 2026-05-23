//
//  NewRoomForm.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/19/26.
//
import SwiftUI

struct NewRoomForm: View {
    @State private var newRoomTitle: String
    @State private var selectedType: RoomType
    @State private var selectedColor: RoomColor

    private let roomToEdit: Room?
    let onSave: (RoomDraft) -> Void
    let onCancel: () -> Void

    init(
        roomToEdit: Room? = nil,
        onSave: @escaping (RoomDraft) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.roomToEdit = roomToEdit
        self.onSave = onSave
        self.onCancel = onCancel
        self._newRoomTitle = State(initialValue: roomToEdit?.title ?? "")
        self._selectedType = State(initialValue: roomToEdit?.type ?? .bedroom)
        self._selectedColor = State(initialValue: roomToEdit?.color ?? .red)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Room Title", text: $newRoomTitle)

                Picker("Room Type", selection: $selectedType) {
                    ForEach(RoomType.allCases) { type in
                        Text(type.title).tag(type)
                    }
                }

                Section("Color") {
                    HStack {
                        ForEach(RoomColor.allCases) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(color.swiftUIColor)
                                        .frame(width: 32, height: 32)

                                    if selectedColor == color {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(color.title)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(roomToEdit == nil ? "New Room" : "Edit Room")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(
                            RoomDraft(
                                title: newRoomTitle,
                                type: selectedType,
                                color: selectedColor
                            )
                        )
                    }
                    .disabled(newRoomTitle.isEmpty)
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
