//
//  NoteRow.swift
//  plopplop
//
//  Created by cheng xi on 13/7/26.
//


import SwiftUI

struct NoteRow: View {

    let note: Note

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            HStack {

                Text(note.title)
                    .font(.headline)

                Spacer()

                if note.isPinned {

                    Image(systemName: "pin.fill")
                        .foregroundStyle(.orange)

                }

            }

            Text(note.content)
                .lineLimit(2)
                .foregroundStyle(.secondary)

            HStack {

                Text(note.senderName)

                Spacer()

                Text(note.createdAt.formatted())

            }
            .font(.caption)
            .foregroundStyle(.tertiary)

        }

        .padding(.vertical, 8)

    }

}