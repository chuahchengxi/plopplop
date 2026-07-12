//
//  NoteDetailView.swift
//  plopplop
//
//  Created by cheng xi on 12/7/26.
//


import SwiftUI

struct NoteDetailView: View {
    let note: Note
    var body: some View {
        NavigationStack {
            List {
                Section("Title") {
                    Text(note.title)
                }
                Section("Content") {
                    Text(note.content)
                        .textSelection(.enabled)
                }
                Section("Information") {
                    LabeledContent(
                        "Sender",
                        value: note.senderName
                    )
                    LabeledContent(
                        "Received",
                        value: note.createdAt.formatted(
                            date: .abbreviated,
                            time: .shortened
                        )
                    )
                    LabeledContent(
                        "UUID",
                        value: note.id.uuidString
                    )
                    .font(.caption2)
                }
            }
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
