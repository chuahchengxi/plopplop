//
//  DraftStore.swift
//  plopplop
//
//  Created by cheng xi on 13/7/26.
//


import Foundation
import SwiftUI
import Combine

@MainActor
final class DraftStore: ObservableObject {
    @Published private(set) var draft = Draft()
    private let fileURL: URL
    init() {
        let documents = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        fileURL = documents.appendingPathComponent("draft.json")

        load()

    }

}
extension DraftStore {

    func update(
        title: String,
        content: String
    ) {

        draft.title = title
        draft.content = content
        draft.lastEdited = .now

        save()

    }

    func clear() {

        draft = Draft()

        try? FileManager.default.removeItem(at: fileURL)

    }

    func restore() -> Draft {

        draft

    }

}
private extension DraftStore {

    func load() {

        guard
            FileManager.default.fileExists(atPath: fileURL.path)
        else {

            draft = Draft()
            return

        }

        do {

            let data = try Data(contentsOf: fileURL)

            draft = try JSONDecoder().decode(
                Draft.self,
                from: data
            )

        } catch {

            draft = Draft()

        }

    }

    func save() {

        do {

            let data = try JSONEncoder().encode(draft)

            try data.write(
                to: fileURL,
                options: .atomic
            )

        } catch {

            print(error)

        }

    }

}
