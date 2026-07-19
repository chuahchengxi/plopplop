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

    var width: Double
    var height: Double

    var file: CanvasFile?

    var type: String
    var text: String

    var pointsData: Data?
    var inkColor: String

    init(
        id: UUID = UUID(),
        x: Double = 0,
        y: Double = 0,
        width: Double = 200,
        height: Double = 80,
        type: String = "text",
        text: String = "",
        file: CanvasFile? = nil,
        pointsData: Data? = nil
    ) {
        self.id = id

        self.x = x
        self.y = y

        self.width = width
        self.height = height

        self.file = file

        self.type = type
        self.text = text

        self.pointsData = pointsData
        self.inkColor = "black"
    }
}
