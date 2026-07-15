//
//  Draft.swift
//  plopplop
//
//  Created by cheng xi on 15/7/26.
//


import Foundation
import SwiftData

@Model
final class Draft {

    @Attribute(.unique)
    var id: UUID

    var title: String
    var body: String

    var createdAt: Date
    var updatedAt: Date

    init(
        title: String = "",
        body: String = ""
    ) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}