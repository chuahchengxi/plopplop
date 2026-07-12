//
//  ReceiveView.swift
//  plopplop
//
//  Created by cheng xi on 11/7/26.
//
import SwiftUI

struct ReceiveView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject
    private var notesStore: NotesStore


    @State
    private var selectedNote: Note?

    @State
    private var showingDeleteConfirmation = false

    @State
    private var noteToDelete: Note?
    var body: some View {
        NavigationStack {
            Group {
                if notesStore.notes.isEmpty {
                    emptyState
                } else {
                    notesList
                }
            }
            .navigationTitle("Received Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedNote) { note in
                NoteDetailView(note: note)
            }
            .confirmationDialog(
                "Delete Note?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(
                    "Delete",
                    role: .destructive
                ) {
                    guard let noteToDelete else {
                        return
                    }

                    notesStore.remove(noteToDelete)

                }

                Button(
                    "Cancel",
                    role: .cancel
                ) { }

            } message: {

                Text(
                    "This note will be permanently removed from this device."
                )

            }

        }

    }

}

private extension ReceiveView {

    var emptyState: some View {

        ContentUnavailableView(
            "No Notes",
            systemImage: "note.text",
            description: Text(
                "Received notes will appear here."
            )
        )

    }

}

private extension ReceiveView {

    var notesList: some View {

        List {

            ForEach(notesStore.notes) { note in

                Button {

                    selectedNote = note

                } label: {

                    NoteRow(note: note)

                }
                .buttonStyle(.plain)
                .swipeActions {

                    Button(
                        role: .destructive
                    ) {

                        noteToDelete = note

                        showingDeleteConfirmation = true

                    } label: {

                        Label(
                            "Delete",
                            systemImage: "trash"
                        )

                    }

                }

            }

        }

    }

}

private struct NoteRow: View {

    let note: Note

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Text(note.title)
                .font(.headline)

            Text(note.content)
                .lineLimit(2)
                .foregroundStyle(.secondary)

            HStack {

                Label(
                    note.senderName,
                    systemImage: "person.circle"
                )

                Spacer()

                Text(
                    note.createdAt.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                )

            }
            .font(.caption)
            .foregroundStyle(.secondary)

        }
        .padding(.vertical, 4)

    }

}
