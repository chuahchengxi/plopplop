//
//  Workspace.swift
//  plopplop
//
//  Created by cheng xi on 16/7/26.
//


import Foundation
import SwiftData

@Model
final class Workspace {
    var id: UUID
    var name: String

    @Relationship(deleteRule: .cascade)
    var objects: [CanvasObject]

    init(
        id: UUID = UUID(),
        name: String,
        objects: [CanvasObject] = []
    ) {
        self.id = id
        self.name = name
        self.objects = objects
    }
}