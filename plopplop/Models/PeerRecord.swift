//
//  PeerRecord.swift
//  plopplop
//
//  Created by cheng xi on 15/7/26.
//


import Foundation
import SwiftData

@Model
final class PeerRecord {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var peerID: String
    var nickname: String
    var lastSeen: Date
    init(
        peerID: String,
        nickname: String
    ) {
        self.id = UUID()
        self.peerID = peerID
        self.nickname = nickname
        self.lastSeen = Date()
    }
}
