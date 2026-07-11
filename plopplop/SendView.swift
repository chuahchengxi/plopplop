//
//  SendView.swift
//  plopplop
//
//  Created by cheng xi on 11/7/26.
//
import SwiftUI

struct SendView: View {
    @EnvironmentObject var manager: MultipeerManager
    @State private var title = ""
    @State private var content = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Note") {
                    TextField("Title", text: $title)
                    TextField(
                        "Write your note...",
                        text: $content,
                        axis: .vertical
                    )
                    .lineLimit(6...12)
                }
                Section {
                    Button("Send Note") {
                        guard !title.isEmpty,
                              !content.isEmpty else {
                            return
                        }
                        let note = Note(
                            id: UUID(),
                            title: title,
                            content: content,
                            dateCreated: Date()
                        )

                        manager.send(note: note)

                        title = ""
                        content = ""
                    }
                }
            }
            .navigationTitle("Share Note")
        }
    }
}
