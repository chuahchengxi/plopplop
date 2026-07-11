//
//  ReceiveView.swift
//  plopplop
//
//  Created by cheng xi on 11/7/26.
//
import SwiftUI

struct ReceiveView: View {
    @EnvironmentObject var manager: MultipeerManager
    var body: some View {
        NavigationStack {
            if let note = manager.receivedNote {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(note.title)
                            .font(.largeTitle)
                            .bold()
                        Text(note.content)
                        Text(note.dateCreated.formatted())
                            .font(.caption)
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView(
                    "No Note Received",
                    systemImage: "note.text"
                )
            }
        }
    }
}
