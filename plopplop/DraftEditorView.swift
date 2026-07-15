//
//  DraftEditorView.swift
//  plopplop
//
//  Created by cheng xi on 15/7/26.
//


import SwiftUI

struct DraftEditorView: View {

    @Bindable
    var draft: Draft

    var body: some View {

        Form {

            Section("Title") {

                TextField(
                    "Title",
                    text: $draft.title
                )
            }

            Section("Body") {

                TextEditor(
                    text: $draft.body
                )
                .frame(
                    minHeight: 300
                )
            }
        }

        .navigationTitle("Edit Draft")

        .onChange(
            of: draft.title
        ) {

            draft.updatedAt = Date()
        }

        .onChange(
            of: draft.body
        ) {

            draft.updatedAt = Date()
        }
    }
}