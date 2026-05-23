//
//  RoomStatsView.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/22/26.
//
import SwiftUI
import SwiftData

struct RoomStatsView: View {
    @Query(sort: \Room.createdAt) private var rooms: [Room]

    var body: some View {
        NavigationStack {
            Group {
                if rooms.isEmpty {
                    ContentUnavailableView {
                        Label("No Stats", systemImage: "chart.bar")
                    } description: {
                        Text("Add rooms to see totals.")
                    }
                } else {
                    List {
                        Section("Overview") {
                            StatRow(title: "Total rooms", value: rooms.count)
                        }

                        Section("By Type") {
                            ForEach(RoomType.allCases) { type in
                                StatRow(title: type.title, value: countRooms(type: type))
                            }
                        }

                        Section("By Color") {
                            ForEach(RoomColor.allCases) { color in
                                HStack {
                                    Circle()
                                        .fill(color.swiftUIColor)
                                        .frame(width: 14, height: 14)

                                    StatRow(title: color.title, value: countRooms(color: color))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Stats")
        }
    }

    func countRooms(type: RoomType) -> Int {
        rooms.filter { room in
            room.type == type
        }.count
    }

    func countRooms(color: RoomColor) -> Int {
        rooms.filter { room in
            room.color == color
        }.count
    }
}

private struct StatRow: View {
    let title: String
    let value: Int

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(value)")
                .foregroundStyle(.secondary)
        }
    }
}
