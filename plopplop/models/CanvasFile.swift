//
//  CanvasFile.swift
//  plopplop
//
//  Created by cheng xi on 16/7/26.
//


import Foundation
import SwiftData

@Model
final class CanvasFile {
    var id: UUID
    var fileName: String
    var fileType: String
    var data: Data

    init(
        id: UUID = UUID(),
        fileName: String,
        fileType: String,
        data: Data
    ) {
        self.id = id
        self.fileName = fileName
        self.fileType = fileType
        self.data = data
    }
}