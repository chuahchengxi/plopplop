//
//  DataStore.swift
//  plopplop
//
//  Created by cheng xi on 4/7/26.
//
import Foundation
struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var senderName: String
    var createdAt: Date
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        senderName: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.senderName = senderName
        self.createdAt = createdAt
    }

}
