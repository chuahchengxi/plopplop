//
//  ReceiveView.swift
//  plopplop
//
//  Created by cheng xi on 11/7/26.
//
import SwiftUI
import SwiftData

struct DraftView: View {

    @Environment(\.modelContext)
    private var modelContext

    @Query(
        sort: \Draft.updatedAt,
        order: .reverse
    )
    private var drafts: [Draft]

    @State
    private var selectedDraft: Draft?

    @State
    private var showingNewDraft = false

    var body: some View {

        NavigationSplitView {

            List(
                drafts,
                selection: $selectedDraft
            ) { draft in

                Text(
                    draft.title.isEmpty
                    ? "Untitled"
                    : draft.title
                )
                .tag(draft)
            }

            .navigationTitle("Drafts")

            .toolbar {

                ToolbarItem {

                    Button {

                        createDraft()

                    } label: {

                        Image(systemName: "plus")
                    }
                }
            }

        } detail: {

            if let selectedDraft {

                DraftEditorView(
                    draft: selectedDraft
                )

            } else {

                ContentUnavailableView(
                    "Select a Draft",
                    systemImage: "square.and.pencil"
                )
            }
        }
    }

    private func createDraft() {

        let draft = Draft()

        modelContext.insert(draft)

        selectedDraft = draft
    }
}
