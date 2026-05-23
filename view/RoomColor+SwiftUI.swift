//
//  RoomColor+SwiftUI.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/22/26.
//
import SwiftUI

extension RoomColor {
    var swiftUIColor: Color {
        switch self {
        case .red:
            .red
        case .green:
            .green
        case .yellow:
            .yellow
        case .blue:
            .blue
        case .purple:
            .purple
        }
    }
}
