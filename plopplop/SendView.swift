//
//  SendView.swift
//  plopplop
//
//  Created by cheng xi on 11/7/26.
//
import SwiftUI
import MultipeerConnectivity

struct SendView: View {
    private enum Field: Int, CaseIterable {
        case title, content}
    @EnvironmentObject var manager: MultipeerManager
    @State private var title = ""
    @State private var content = ""
    @FocusState private var focusedField: Field?
    var body: some View {
        NavigationStack {
            Form {
                Section("Note") {
                    TextField("Title", text: $title)
                        .focused($focusedField, equals: .title)
                    TextField(
                        "Write your note...",
                        text: $content,
                        axis: .vertical
                    )
                    .lineLimit(6...12)
                    .focused($focusedField, equals: .content)
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
                    .disabled(manager.connectedPeers.isEmpty)
                }
            }
            .navigationTitle("Share Note")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
    }
}
