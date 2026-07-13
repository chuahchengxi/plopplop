//
//  Draft.swift
//  plopplop
//
//  Created by cheng xi on 13/7/26.
//
import Foundation
struct Draft: Codable, Equatable {

    var title: String

    var content: String

    var lastEdited: Date

    init(
        title: String = "",
        content: String = "",
        lastEdited: Date = .now
    ) {

        self.title = title
        self.content = content
        self.lastEdited = lastEdited

    }

    var isEmpty: Bool {

        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

    }

}
