//
//  RoomView.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/19/26.
//
import SwiftUI

struct RoomView: View {
    var room: Room
    
    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(room.color.swiftUIColor)
                .frame(width: 64, height: 64)

            Text(room.type.title)
                .font(.title2)
        }
        .navigationTitle(room.title)
    }
}
