//
//  InkColor.swift
//  plopplop
//
//  Created by cheng xi on 18/7/26.
//


import SwiftUI

enum InkColor: String {
    case black
    case red
    case blue
    case green
    case yellow

    var color: Color {
        switch self {
        case .black:
            return .black

        case .red:
            return .red

        case .blue:
            return .blue

        case .green:
            return .green

        case .yellow:
            return .yellow
        }
    }
}