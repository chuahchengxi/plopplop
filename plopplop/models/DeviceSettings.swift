//
//  DeviceSettings.swift
//  plopplop
//
//  Created by cheng xi on 15/7/26.
//


import Foundation
import SwiftData

@Model
final class DeviceSettings {

    @Attribute(.unique)
    var id: UUID

    var nickname: String
    var isDiscoverable: Bool

    init(
        nickname: String = "Anonymous",
        isDiscoverable: Bool = true
    ) {
        self.id = UUID()
        self.nickname = nickname
        self.isDiscoverable = isDiscoverable
    }
}