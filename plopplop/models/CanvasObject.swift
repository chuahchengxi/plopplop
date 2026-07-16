//
//  CanvasObject.swift
//  plopplop
//
//  Created by cheng xi on 16/7/26.
//

import Foundation
import SwiftData

@Model
final class CanvasObject {
    var id: UUID
    var x: Double
    var y: Double

    var file: CanvasFile?

    var type: String
    var text: String

    init(
        id: UUID = UUID(),
        x: Double = 0,
        y: Double = 0,
        type: String = "text",
        text: String = "",
        file: CanvasFile? = nil
    ) {
        self.id = id
        self.x = x
        self.y = y
        self.type = type
        self.text = text
        self.file = file
    }
}
