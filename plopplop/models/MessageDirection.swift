//
//  MessageDirection.swift
//  plopplop
//
//  Created by cheng xi on 15/7/26.
//


import Foundation
import SwiftData

enum MessageDirection: String, Codable {

    case sent
    case received
}

@Model
final class ChatMessage {

    @Attribute(.unique)
    var id: UUID

    var text: String
    var senderNickname: String
    var direction: MessageDirection
    var createdAt: Date

    init(
        text: String,
        senderNickname: String,
        direction: MessageDirection
    ) {
        self.id = UUID()
        self.text = text
        self.senderNickname = senderNickname
        self.direction = direction
        self.createdAt = Date()
    }
}