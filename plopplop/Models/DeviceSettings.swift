//
//  DeviceSettings.swift
//  plopplop
//
//  Created by cheng xi on 12/7/26.
//
import Foundation
import SwiftUI
import Combine

@MainActor
final class DeviceSettings: ObservableObject {
    private let nicknameKey = "DeviceNickname"
    @Published var nickname: String {
        didSet {
            UserDefaults.standard.set(nickname, forKey: nicknameKey)
        }
    }
    init() {
        if let savedName = UserDefaults.standard.string(forKey: nicknameKey),
           !savedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            nickname = savedName
        } else {
            nickname = ""
        }
    }
    var hasNickname: Bool {
        !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    func saveNickname(_ newName: String) {
        nickname = newName
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
