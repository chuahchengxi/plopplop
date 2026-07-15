 //
//  ContentView.swift
//  plopplop
//
//  Created by cheng xi on 4/7/26.
//
import SwiftUI
import SwiftData

struct HomeView: View {

    @Query(
        sort: \Draft.updatedAt,
        order: .reverse
    )
    private var drafts: [Draft]

    var body: some View {

        NavigationStack {

            List {
                if drafts.isEmpty {
                    ContentUnavailableView(
                        "No Drafts",
                        systemImage: "square.and.pencil",
                        description: Text(
                            "Create your first draft."
                        )
                    )
                } else {
                    ForEach(drafts) { draft in
                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {
                            Text(
                                draft.title.isEmpty
                                ? "Untitled"
                                : draft.title
                            )
                            .font(.headline)
                            Text(draft.body)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
            }

            .navigationTitle("plopplop")
        }
    }
}
